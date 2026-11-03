/// 执行页：本次序列逐项标记 → 全部完成确认晋级 / 标记未完成回退。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

class ExecutePage extends StatefulWidget {
  final TrainingItem item;
  final RepData startState;
  const ExecutePage({super.key, required this.item, required this.startState});

  @override
  State<ExecutePage> createState() => _ExecutePageState();
}

class _ExecutePageState extends State<ExecutePage> {
  late final List<bool> _checked;
  late final List<int> _seq;

  @override
  void initState() {
    super.initState();
    _seq = widget.startState.sequence;
    _checked = List.filled(_seq.length, false);
  }

  int get _done => _checked.where((e) => e).length;

  /// 依次从上往下勾选：只能勾选上一项已完成后的下一项；
  /// 取消时只允许取消最后勾选的那一项，保证顺序不被打破。
  void _toggle(int i) {
    setState(() {
      if (_checked[i]) {
        final isLastChecked = i == _seq.length - 1 || !_checked.skip(i + 1).any((e) => e);
        if (isLastChecked) _checked[i] = false;
      } else {
        if (i == 0 || _checked[i - 1]) _checked[i] = true;
      }
    });
  }

  Future<void> _confirmDone() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = AppScope.of(context).repository;
    final item = widget.item;
    final cur = await repo.getProgress(item.id!) ?? ProgressEngine.initialState(item);
    final next = ProgressEngine.advance(item, cur);
    if (next == null) {
      // 整个训练完成：记 DONE，位置留在末位。
      await repo.updateItemStatus(item.id!, 'DONE');
    }
    await repo.saveProgress(item.id!, next ?? cur);
    await repo.addLog(LogEntry(
      itemId: item.id!,
      logDate: DateTime.now().toIso8601String().substring(0, 10),
      grade: cur.grade,
      level: cur.level,
      rep: cur.rep,
      target: ProgressEngine.seqToString(_seq),
      result: 'PASS',
      createdAt: DateTime.now().toIso8601String(),
    ));
    if (!mounted) return;
    _toast(next == null ? l10n.toastDoneFinish : l10n.toastAdvance);
    Navigator.of(context).pop();
  }

  Future<void> _markFail() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = AppScope.of(context).repository;
    final item = widget.item;
    final cur = await repo.getProgress(item.id!) ?? ProgressEngine.initialState(item);
    final st = ProgressEngine.recede(item, cur);
    await repo.saveProgress(item.id!, st);
    final rule = item.failRule == 'RECEDE' ? l10n.failRecede : l10n.failStay;
    await repo.addLog(LogEntry(
      itemId: item.id!,
      logDate: DateTime.now().toIso8601String().substring(0, 10),
      grade: cur.grade,
      level: cur.level,
      rep: cur.rep,
      target: ProgressEngine.seqToString(_seq),
      result: 'FAIL',
      note: rule,
      createdAt: DateTime.now().toIso8601String(),
    ));
    if (!mounted) return;
    _toast(l10n.toastFail(rule));
    Navigator.of(context).pop();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1600)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = _seq.length;
    final pct = total == 0 ? 0.0 : _done / total;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.executeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(l10n.todayTarget,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(l10n.checkedCount(_done, total),
                  style: const TextStyle(fontSize: 12, color: AppColors.mut)),
            ],
          ),
          if (widget.item.goalText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.accSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(l10n.goalHint(widget.item.goalText),
                  style: const TextStyle(fontSize: 12, color: AppColors.mut, height: 1.6)),
            ),
          ],
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.line,
              valueColor: const AlwaysStoppedAnimation(AppColors.acc),
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _seq.length; i++)
            _CheckItem(
              value: _seq[i],
              index: i,
              checked: _checked[i],
              locked: !_checked[i] && i > 0 && !_checked[i - 1],
              onTap: () => _toggle(i),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _done == total ? _confirmDone : null,
            child: Text(l10n.confirmDone),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: _markFail, child: Text(l10n.markFail)),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final int value;
  final int index;
  final bool checked;
  final bool locked;
  final VoidCallback onTap;
  const _CheckItem({
    required this.value,
    required this.index,
    required this.checked,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bg = checked
        ? AppColors.okSoft
        : (locked ? AppColors.dim : AppColors.card);
    final border = checked ? AppColors.okSoft : (locked ? AppColors.dim : AppColors.line);
    final boxColor = checked
        ? AppColors.ok
        : (locked ? AppColors.mut : AppColors.card);
    final boxBorder = checked ? AppColors.ok : (locked ? AppColors.mut : AppColors.line);
    return InkWell(
      onTap: locked ? null : onTap,
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
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: boxBorder, width: 2),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Text(l10n.itemIndex(index + 1),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mut)),
            const Spacer(),
            Text.rich(TextSpan(children: [
              TextSpan(text: '${l10n.refLabel} ',
                  style: const TextStyle(fontSize: 12, color: AppColors.mut)),
              TextSpan(text: '$value',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 17, fontWeight: FontWeight.w600)),
            ])),
          ],
        ),
      ),
    );
  }
}
