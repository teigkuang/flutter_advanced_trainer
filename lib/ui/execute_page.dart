/// 执行页：本次序列逐项实施 → 点某一项跳对应任务类型的实施子页 → 完成动作返回后该项才推进。
///
/// 交互口径（第五轮定稿）：
///   - 运动：跳节拍器子页（开始/暂停/结束，结束=完成返回推进）
///   - 事务 / 学习：跳清单子页（循环取条目，勾满参考量推进）
///   - 记录：跳书写子页（一次一笔，提交满参考量推进）
///   - 已完成项不回看不重进（查看走相关记录页）；失败可再次进入；整次失败走"标记未完成"。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import 'checklist_page.dart';
import 'metronome_page.dart';
import 'note_page.dart';
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
  late final List<bool> _done;
  late final List<int> _seq;
  int _listCursor = 0; // 事务/学习：全局清单游标（仅整项完成时推进）

  @override
  void initState() {
    super.initState();
    _seq = widget.startState.sequence;
    _done = List.filled(_seq.length, false);
  }

  int get _doneCount => _done.where((e) => e).length;
  int get _current => _done.indexOf(false); // 当前项（第一个未完成）

  /// 进入某一项的实施子页；子页完成返回后该项才推进。
  Future<void> _enter(int i) async {
    final ref = _seq[i];
    final type = widget.item.taskType;
    final cur = ProgressState(
        widget.startState.grade, widget.startState.level, widget.startState.rep);
    if (type == '记录') {
      final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => NotePage(item: widget.item, ref: ref, cur: cur),
      ));
      if (ok == true && mounted) setState(() => _done[i] = true);
      return;
    }
    if (type == '事务' || type == '学习') {
      final next = await Navigator.of(context).push<int>(MaterialPageRoute(
        builder: (_) => ChecklistPage(
            item: widget.item, ref: ref, cursorStart: _listCursor),
      ));
      if (next != null && mounted) {
        setState(() {
          _done[i] = true;
          _listCursor = next;
        });
      }
      return;
    }
    // 运动（默认）：结束=完成返回推进；若节拍器里改了 BPM，写回任务保持一致。
    final res = await Navigator.of(context).push<MetronomeResult>(MaterialPageRoute(
      builder: (_) => MetronomePage(
          item: widget.item, ref: ref, initialBpm: widget.item.bpm),
    ));
    if (res != null && res.finished && mounted) {
      setState(() => _done[i] = true);
      if (res.bpm != widget.item.bpm) {
        await AppScope.of(context).repository.updateItemBpm(widget.item.id!, res.bpm);
      }
    }
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
    final pct = total == 0 ? 0.0 : _doneCount / total;
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
              Text(l10n.checkedCount(_doneCount, total),
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
            _ItemCard(
              value: _seq[i],
              index: i,
              done: _done[i],
              current: i == _current,
              locked: !_done[i] && i > 0 && !_done[i - 1],
              onTap: _done[i] || (i > 0 && !_done[i - 1]) ? null : () => _enter(i),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _doneCount == total ? _confirmDone : null,
            child: Text(l10n.confirmDone),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: _markFail, child: Text(l10n.markFail)),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final int value;
  final int index;
  final bool done;
  final bool current;
  final bool locked;
  final VoidCallback? onTap;
  const _ItemCard({
    required this.value,
    required this.index,
    required this.done,
    required this.current,
    required this.locked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bg = done
        ? AppColors.okSoft
        : (locked ? AppColors.dim : (current ? AppColors.accSoft : AppColors.card));
    final border = done
        ? AppColors.okSoft
        : (locked ? AppColors.dim : (current ? AppColors.acc : AppColors.line));
    final boxColor = done
        ? AppColors.ok
        : (locked ? AppColors.mut : AppColors.card);
    final boxBorder = done ? AppColors.ok : (locked ? AppColors.mut : AppColors.line);
    return InkWell(
      onTap: onTap,
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
              child: done
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
            const SizedBox(width: 10),
            if (done)
              const Icon(Icons.check_circle, size: 18, color: AppColors.ok)
            else if (current)
              Row(children: [
                Text(l10n.execEnter,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.acc)),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.acc),
              ])
            else if (locked)
              const Icon(Icons.lock_outline, size: 16, color: AppColors.mut)
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
