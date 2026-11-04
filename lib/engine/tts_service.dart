/// 全局唯一的朗读服务（单例），封装 flutter_tts。
///
/// 职责：
///   - 把「标题 + 正文」经 language_detector 切成语言片段，逐片段 setLanguage + speak 串行朗读。
///   - 播放/暂停/继续/停止状态机：idle → playing → paused → (读完/停止) → idle。
///   - 跨平台统一「断点续读」：flutter_tts 无可靠的平台级 pause/continue，
///     故暂停 = 记录断点（当前片段索引 + 片内字符位置）+ stop；继续 = 从断点重读。
///     断点位置由 progress 回调（Android onRangeStart 语义）提供。
///   - 全局唯一：同时只允许一条在朗读；stop() 可被页面 dispose 调用。
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'language_detector.dart';

/// 朗读状态。
enum ReadState { idle, playing, paused }

/// 一段待朗读的文本 + 语言。
class ReadUnit {
  final String text;
  final TtsLang lang;
  const ReadUnit(this.text, this.lang);
}

class TtsService {
  TtsService._() {
    _tts.setStartHandler(() => _setState(ReadState.playing));
    _tts.setPauseHandler(() => _setState(ReadState.paused));
    _tts.setCompletionHandler(_onUnitDone);
    _tts.setCancelHandler(() => _setState(ReadState.idle));
    _tts.setErrorHandler((_) => _stopClean());
    // progress（Android onRangeStart）：记录当前片内朗读起点，供断点续读。
    _tts.setProgressHandler((text, start, end, word) {
      _charPos = start;
    });
  }

  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();

  ReadState _state = ReadState.idle;
  List<ReadUnit> _units = const [];
  int _index = 0; // 当前片段索引
  int _charPos = 0; // 当前片段内朗读起点（断点续读用）

  /// 当前状态（供 UI 重建）。
  ReadState get state => _state;

  /// 是否正在朗读或已暂停（用于 UI 判断是否有活动播放）。
  bool get active => _state != ReadState.idle;

  /// 当前朗读进度：已完成片段数 / 总片段数。
  ({int done, int total}) get progress =>
      _units.isEmpty ? (done: 0, total: 0) : (done: _index, total: _units.length);

  /// UI 监听：状态或进度变化时刷新。
  VoidCallback? onChanged;

  void _setState(ReadState s) {
    if (_state == s) return;
    _state = s;
    onChanged?.call();
  }

  /// 开始朗读一组片段（通常为「标题 + 正文」切分结果）。已有朗读则先停。
  Future<void> speakAll(List<ReadUnit> units) async {
    await stop();
    if (units.isEmpty) return;
    _units = units;
    _index = 0;
    _charPos = 0;
    await _speakCurrent();
  }

  /// 播放 / 暂停 / 继续 的入口（由按钮触发）。
  Future<void> toggle() async {
    switch (_state) {
      case ReadState.idle:
        if (_units.isEmpty) return;
        await _speakCurrent();
      case ReadState.playing:
        await pause();
      case ReadState.paused:
        await resume();
    }
  }

  Future<void> _speakCurrent() async {
    if (_index >= _units.length) {
      await _stopClean();
      return;
    }
    final unit = _units[_index];
    // 断点续读：从 _charPos 起读当前片段剩余部分。
    final text = _charPos > 0 && _charPos < unit.text.length
        ? unit.text.substring(_charPos)
        : unit.text;
    _charPos = 0;
    _setState(ReadState.playing);
    try {
      await _tts.setLanguage(unit.lang.locale);
      // 不 await speak 的返回值：串行推进统一由 completion 回调驱动，
      // 避免 Android awaitSpeakCompletion 与 completion 回调双触发。
      unawaited(_tts.speak(text));
    } catch (_) {
      // 语言不可用等错误：跳过该片段继续，避免卡死。
      _onUnitDone();
    }
  }

  /// 暂停：断点续读（记断点 + stop）。
  Future<void> pause() async {
    if (_state != ReadState.playing) return;
    // _charPos 已在 progress 回调中更新为当前片内位置。
    try {
      await _tts.stop();
    } catch (_) {}
    _setState(ReadState.paused);
  }

  /// 继续：从断点重新朗读当前片段。
  Future<void> resume() async {
    if (_state != ReadState.paused) return;
    await _speakCurrent();
  }

  /// 停止并复位。
  Future<void> stop() async {
    if (_state == ReadState.idle && _units.isEmpty) return;
    await _stopClean();
  }

  Future<void> _stopClean() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _units = const [];
    _index = 0;
    _charPos = 0;
    _setState(ReadState.idle);
  }

  /// 单个片段读完：推进下一片段；全部读完则复位。
  void _onUnitDone() {
    if (_state == ReadState.idle) return; // 已被 stop/取消
    _index++;
    _charPos = 0;
    if (_index >= _units.length) {
      _stopClean();
    } else {
      _speakCurrent();
    }
  }

  /// 便捷：把「标题 + 正文」切成朗读单元（标题在前，正文逐行切分）。
  static List<ReadUnit> unitsFor(String title, String body) {
    final out = <ReadUnit>[];
    void addLine(String line) {
      final t = line.trim();
      if (t.isEmpty) return;
      for (final s in splitByLanguage(t)) {
        out.add(ReadUnit(s.text, s.lang));
      }
    }

    if (title.trim().isNotEmpty) addLine(title);
    for (final line in body.split('\n')) {
      addLine(line);
    }
    return out;
  }
}
