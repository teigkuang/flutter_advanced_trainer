/// 运动实施子页 · 节拍器：BPM 40~208 可调，开始播放嘀嗒声，暂停停止，结束=完成当前项返回推进。
///
/// 节拍声来源（实现层定）：`audioplayers` 播放内置短促 beep（assets/audio/metronome.wav），
/// 由定时器按 60000/BPM 间隔触发，同时做一个节拍指示点视觉反馈。
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/models.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

class MetronomePage extends StatefulWidget {
  final TrainingItem item;
  final int ref; // 当前项参考量
  final int initialBpm; // 任务级 BPM（默认 120）
  const MetronomePage({
    super.key,
    required this.item,
    required this.ref,
    this.initialBpm = 120,
  });

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

/// 节拍器返回结果：是否完成当前项 + 结束后 BPM（供执行页写回任务，保持同步）。
class MetronomeResult {
  final bool finished;
  final int bpm;
  const MetronomeResult(this.finished, this.bpm);
}

class _MetronomePageState extends State<MetronomePage> {
  static const _minBpm = 40;
  static const _maxBpm = 208;

  late int _bpm;
  String _state = 'idle'; // idle / run / pause
  Timer? _timer;
  int _beat = 0; // 已播的嘀嗒数（仅用于节拍指示点闪烁，不显示数字）
  AudioPlayer? _player;
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    _bpm = widget.initialBpm.clamp(_minBpm, _maxBpm);
    _initAudio();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _initAudio() async {
    try {
      final p = AudioPlayer();
      await p.setSource(AssetSource('audio/metronome.wav'));
      await p.setReleaseMode(ReleaseMode.stop);
      _player = p;
      _audioReady = true;
    } catch (_) {
      // 音频初始化失败（无音频设备等）时静默降级，仅保留视觉节拍指示。
    }
  }

  void _tick() async {
    final p = _player;
    if (_audioReady && p != null) {
      try {
        await p.stop();
        await p.resume();
      } catch (_) {}
    }
    if (mounted) setState(() => _beat++);
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_state == 'run') {
      _timer = Timer.periodic(
        Duration(milliseconds: 60000 ~/ _bpm),
        (_) => _tick(),
      );
    }
  }

  void _adjust(int delta) {
    setState(() {
      _bpm = (_bpm + delta).clamp(_minBpm, _maxBpm);
    });
    _restartTimer();
  }

  /// 点击 BPM 数字弹出输入框，手动输入 40~208。
  Future<void> _askBpm() async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: '$_bpm');
    int? parse(String t) {
      final v = int.tryParse(t.trim());
      if (v == null) return null;
      return v.clamp(_minBpm, _maxBpm);
    }

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.metronomeBpm),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (t) {
            final v = parse(t);
            if (v != null) Navigator.of(ctx).pop(v);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              final v = parse(ctrl.text);
              if (v != null) Navigator.of(ctx).pop(v);
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() => _bpm = result);
      _restartTimer();
    }
  }

  void _start() {
    setState(() => _state = 'run');
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: 60000 ~/ _bpm),
      (_) => _tick(),
    );
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _state = 'pause');
  }

  void _end() {
    // 结束 = 完成当前项，返回推进；同时把当前 BPM 带回（供执行页写回任务）
    _timer?.cancel();
    Navigator.of(context).pop(MetronomeResult(true, _bpm));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final running = _state == 'run';
    return Scaffold(
      appBar: AppBar(title: Text('${l10n.typeSport} · ${l10n.metronomeTitle}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                Text(l10n.metronomeBpm,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _IconBtn(
                      icon: Icons.remove,
                      onTap: _bpm <= _minBpm ? null : () => _adjust(-1),
                      color: AppColors.acc,
                    ),
                    InkWell(
                      onTap: _askBpm,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 96,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: running ? AppColors.accSoft : AppColors.paper,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: running ? AppColors.acc : AppColors.line),
                        ),
                        child: Text('$_bpm',
                            style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: running ? AppColors.acc : AppColors.ink)),
                      ),
                    ),
                    _IconBtn(
                      icon: Icons.add,
                      onTap: _bpm >= _maxBpm ? null : () => _adjust(1),
                      color: AppColors.acc,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _state == 'idle'
                      ? l10n.metronomeIdle
                      : (_state == 'pause' ? l10n.metronomePaused : l10n.metronomeRunning),
                  style: const TextStyle(fontSize: 12, color: AppColors.mut),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(l10n.metronomeItem(widget.ref),
                    style: const TextStyle(fontSize: 13, color: Colors.white)),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 60),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: running && _beat.isOdd ? AppColors.acc : Colors.white24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: running ? null : _start,
                  child: Text(l10n.metronomeStart),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: running ? _pause : null,
                  child: Text(l10n.metronomePause),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _end,
            child: Text(l10n.metronomeEnd),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _IconBtn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.dim : AppColors.accSoft,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: onTap == null ? AppColors.dim : color),
      ),
    );
  }
}
