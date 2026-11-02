/// 执行页：本次序列逐项标记 → 全部完成确认晋级 / 标记未完成回退。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
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

  Future<void> _confirmDone() async {
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
    _toast(next == null ? '全部完成，已收官' : '已完成并晋级');
    Navigator.of(context).pop();
  }

  Future<void> _markFail() async {
    final repo = AppScope.of(context).repository;
    final item = widget.item;
    final cur = await repo.getProgress(item.id!) ?? ProgressEngine.initialState(item);
    final st = ProgressEngine.recede(item, cur);
    await repo.saveProgress(item.id!, st);
    await repo.addLog(LogEntry(
      itemId: item.id!,
      logDate: DateTime.now().toIso8601String().substring(0, 10),
      grade: cur.grade,
      level: cur.level,
      rep: cur.rep,
      target: ProgressEngine.seqToString(_seq),
      result: 'FAIL',
      note: item.failRule == 'RECEDE' ? '回退' : '停留',
      createdAt: DateTime.now().toIso8601String(),
    ));
    if (!mounted) return;
    _toast('已标记未完成 · ${item.failRule == 'RECEDE' ? '回退' : '停留'}');
    Navigator.of(context).pop();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1600)));
  }

  @override
  Widget build(BuildContext context) {
    final total = _seq.length;
    final pct = total == 0 ? 0.0 : _done / total;
    return Scaffold(
      appBar: AppBar(title: const Text('执行任务')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text('本次要完成',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('已勾选 $_done / $total 项',
                  style: const TextStyle(fontSize: 12, color: AppColors.mut)),
            ],
          ),
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
              onTap: () => setState(() => _checked[i] = !_checked[i]),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _done == total ? _confirmDone : null,
            child: const Text('确认完成'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: _markFail, child: const Text('标记未完成')),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final int value;
  final int index;
  final bool checked;
  final VoidCallback onTap;
  const _CheckItem({
    required this.value,
    required this.index,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: checked ? AppColors.okSoft : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: checked ? AppColors.okSoft : AppColors.line),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: checked ? AppColors.ok : AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: checked ? AppColors.ok : AppColors.line, width: 2),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Text('($value)',
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('第 ${index + 1} 项',
                style: const TextStyle(fontSize: 12, color: AppColors.mut)),
          ],
        ),
      ),
    );
  }
}
