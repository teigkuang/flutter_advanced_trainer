/// 记录实施子页 · 书写：一次提交一笔，参考量=需提交笔数；禁止空提交。
///
/// 每提交一笔即写一条 completion_log（result=NOTE，note=内容，target=所属完成位置）。
/// 提交满参考量 = 完成当前项返回推进；中途退出返回 null（该项未完成）。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

class NotePage extends StatefulWidget {
  final TrainingItem item;
  final int ref; // 参考量（需提交笔数）
  final ProgressState cur; // 当前进度位置（记录所属位置）
  const NotePage({
    super.key,
    required this.item,
    required this.ref,
    required this.cur,
  });

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _text = TextEditingController();
  int _submitted = 0;
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String get _posText =>
      '${ProgressEngine.gradeTitle(widget.cur.grade)}・第${widget.cur.level + 1}级・第${widget.cur.rep + 1}次任务';

  bool get _canSubmit => !_saving && _text.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _saving = true);
    final repo = AppScope.of(context).repository;
    final now = DateTime.now();
    await repo.addLog(LogEntry(
      itemId: widget.item.id!,
      logDate: now.toIso8601String().substring(0, 10),
      grade: widget.cur.grade,
      level: widget.cur.level,
      rep: widget.cur.rep,
      target: _posText,
      result: 'NOTE',
      note: _text.text.trim(),
      createdAt: now.toIso8601String(),
    ));
    _text.clear();
    if (!mounted) return;
    setState(() {
      _submitted++;
      _saving = false;
    });
    if (_submitted >= widget.ref) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = widget.ref;
    return Scaffold(
      appBar: AppBar(title: Text('${l10n.typeRecord} · ${l10n.noteTitle}')),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.noteNeed(total),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(l10n.notePos(_posText),
                    style: const TextStyle(fontSize: 12, color: AppColors.mut)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : _submitted / total,
                    minHeight: 8,
                    backgroundColor: AppColors.line,
                    valueColor: const AlwaysStoppedAnimation(AppColors.acc),
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.noteSubmitted(_submitted, total),
                    style: const TextStyle(fontSize: 12, color: AppColors.mut)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            minLines: 5,
            maxLines: 12,
            maxLength: 2000,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.noteHint,
              counterText: '',
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _canSubmit ? _submit : null,
            child: Text(_saving ? l10n.noteSaving : l10n.noteSubmit),
          ),
        ],
      ),
    );
  }
}
