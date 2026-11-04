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
import '../l10n/app_localizations.dart';
import 'theme.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
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
    Navigator.of(context).pop(next);
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
    return InkWell(
      onTap: locked ? null : () => _toggle(i),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            AnimatedContainer(
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
          ],
        ),
      ),
    );
  }
}
