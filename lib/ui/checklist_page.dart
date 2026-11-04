/// 事务 / 学习实施子页 · 清单：从清单文件循环取条目逐条勾选，勾满参考量=完成当前项返回推进。
///
/// 游标规则：从 `cursorStart` 起点顺序取参考量条（取尽回开头）；
/// 中途退出重进仍从该项起点重新勾（游标仅在整项完成时推进）。
/// 完成时返回推进后的新游标（int）；中途退出返回 null。
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../engine/checklist_parser.dart';
import '../engine/models.dart';
import '../engine/tts_service.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

/// 清单子页完成时的返回结果：推进后的游标 + 本次实际勾选的处理事项文本。
/// 事务任务借此把"这次处理了哪些事情"带回去，随 PASS 记录落库，供后续回顾。
class ChecklistResult {
  final int next; // 推进后的全局清单游标
  final List<String> texts; // 本次勾选条目的标题（如 扫地/洗衣服/倒垃圾）
  const ChecklistResult({required this.next, required this.texts});
}

class ChecklistPage extends StatefulWidget {
  final TrainingItem item;
  final int ref; // 当前项参考量（需勾选条数）
  final int cursorStart; // 该项清单起点（全局清单游标）
  const ChecklistPage({
    super.key,
    required this.item,
    required this.ref,
    required this.cursorStart,
  });

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  List<ChecklistEntry> _entries = const [];
  List<bool> _checked = const [];
  bool _loading = true;
  bool _loadError = false;
  int _taken = 0;
  int _playingIndex = -1; // 当前正在朗读/已暂停的卡片索引，-1 表示无
  final TtsService _tts = TtsService.instance;

  @override
  void initState() {
    super.initState();
    _tts.onChanged = _onTtsChanged;
    _load();
  }

  @override
  void dispose() {
    _tts.onChanged = null;
    // 离开清单页：停止全局朗读，复位按钮。
    _tts.stop();
    super.dispose();
  }

  /// TTS 状态/进度变化：若回到 idle，则复位正在播放的卡片按钮。
  void _onTtsChanged() {
    if (!mounted) return;
    if (_tts.state == ReadState.idle) {
      if (_playingIndex != -1) {
        setState(() => _playingIndex = -1);
      }
    } else {
      // 进度推进时刷新进度显示（按钮状态不变，仅进度文案变化）
      if (_playingIndex != -1) setState(() {});
    }
  }

  /// 点击播放/暂停/继续按钮。
  void _onReadPressed(int i) {
    final e = _at(i);
    // 若点的是别的卡片正在朗读，先停掉那条，再开始这条。
    if (_playingIndex != -1 && _playingIndex != i) {
      _tts.stop();
    }
    if (_playingIndex == i) {
      // 同一张卡：播放↔暂停↔继续 切换。
      _tts.toggle();
      return;
    }
    // 开始朗读这条。
    _playingIndex = i;
    _tts.speakAll(TtsService.unitsFor(e.title, e.body));
    setState(() {});
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final path = widget.item.listFilePath;
      if (path.isEmpty || !File(path).existsSync()) {
        if (mounted) setState(() => _loadError = true);
        return;
      }
      final text = await File(path).readAsString();
      final entries = parseChecklistFile(text);
      if (entries.isEmpty) {
        if (mounted) setState(() => _loadError = true);
        return;
      }
      final taken = widget.ref > 0 ? widget.ref : 1;
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _taken = taken;
        _checked = List.filled(taken, false);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadError = true);
    }
  }

  ChecklistEntry _at(int k) =>
      _entries[(widget.cursorStart + k) % _entries.length];

  int get _done => _checked.where((e) => e).length;

  void _toggle(int i) {
    if (i > 0 && !_checked[i - 1]) return; // 顺序勾选
    setState(() => _checked[i] = !_checked[i]);
  }

  void _finish() {
    final next = (widget.cursorStart + _taken) % _entries.length;
    final texts = <String>[
      for (int k = 0; k < _taken; k++)
        if (_checked[k]) _at(k).title,
    ];
    Navigator.of(context).pop(ChecklistResult(next: next, texts: texts));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.item.taskType == '学习'
        ? '${l10n.typeStudy} · ${l10n.checklistTitle}'
        : '${l10n.typeTask} · ${l10n.checklistTitle}';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError
              ? Center(child: Text(l10n.checklistMissing))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.accSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.checklistLoop(widget.item.listFileName.isEmpty
                            ? l10n.checklistFileLabel
                            : widget.item.listFileName),
                        style: const TextStyle(fontSize: 12, color: AppColors.mut, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(l10n.checklistNeed(_taken),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text(l10n.checkedCount(_done, _taken),
                            style: const TextStyle(fontSize: 12, color: AppColors.mut)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _taken == 0 ? 0 : _done / _taken,
                        minHeight: 8,
                        backgroundColor: AppColors.line,
                        valueColor: const AlwaysStoppedAnimation(AppColors.acc),
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < _taken; i++) _entryCard(l10n, i),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _done == _taken ? _finish : null,
                      child: Text(l10n.checklistFinish),
                    ),
                  ],
                ),
    );
  }

  /// 学习/事务条目正文的 Markdown 样式：贴合 App 主题（暖橙、小字号、代码高亮）。
  MarkdownStyleSheet _mdStyle(BuildContext context) {
    final base = Theme.of(context);
    return MarkdownStyleSheet.fromTheme(base).copyWith(
      p: const TextStyle(fontSize: 12, color: AppColors.mut, height: 1.55),
      strong: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
      em: const TextStyle(fontStyle: FontStyle.italic),
      code: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 11,
        color: AppColors.acc,
        backgroundColor: AppColors.accSoft,
      ),
      listBullet: const TextStyle(color: AppColors.acc),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.dim,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _entryCard(AppLocalizations l10n, int i) {
    final e = _at(i);
    final checked = _checked[i];
    final locked = !checked && i > 0 && !_checked[i - 1];
    final bg = checked ? AppColors.okSoft : (locked ? AppColors.dim : AppColors.card);
    final border = checked ? AppColors.okSoft : (locked ? AppColors.dim : AppColors.line);
    // 朗读按钮状态：本卡正在播放/已暂停。
    final isThisPlaying = _playingIndex == i && _tts.state == ReadState.playing;
    final isThisPaused = _playingIndex == i && _tts.state == ReadState.paused;
    final canRead = !locked; // 解锁的条目才可朗读
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧独立勾选图标：点击完成勾选（保持顺序约束），不再点击整卡。
          GestureDetector(
            onTap: locked ? null : () => _toggle(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: checked ? AppColors.ok : (locked ? AppColors.mut : AppColors.card),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: checked ? AppColors.ok : (locked ? AppColors.mut : AppColors.line),
                    width: 2),
              ),
              child: checked ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (e.body.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  MarkdownBody(
                    data: e.body,
                    styleSheet: _mdStyle(context),
                    shrinkWrap: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 右下角：播放 / 暂停 / 继续 按钮。
          IconButton(
            onPressed: canRead ? () => _onReadPressed(i) : null,
            visualDensity: VisualDensity.compact,
            tooltip: isThisPlaying
                ? l10n.readPause
                : (isThisPaused ? l10n.readResume : l10n.readPlay),
            icon: Icon(
              isThisPlaying
                  ? Icons.pause_circle
                  : (isThisPaused ? Icons.play_circle : Icons.play_circle_outline),
              color: isThisPlaying || isThisPaused
                  ? AppColors.acc
                  : (canRead ? AppColors.acc : AppColors.mut),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
