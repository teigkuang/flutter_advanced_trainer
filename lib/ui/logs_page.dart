/// 相关记录页：展示某任务完成记录。
///
/// 任务类型分支（第五轮定稿 + 本轮修订）：
///   - 其他类型：PASS 完成记录，文案含完成时间与完成位置，不跳详情。
///   - 记录类型：只展示"任务完成记录"条目（每次完成一条 = PASS 记录），
///     点击某次 → 详情页综合展示该次（同阶/级/次位置）的全部书写记录。
/// 均按时间倒序。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import 'log_detail_page.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

class LogsPage extends StatefulWidget {
  final int itemId;
  const LogsPage({super.key, required this.itemId});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  TrainingItem? _item;
  List<LogEntry> _logs = const []; // 列表展示条目（其他类型/记录类型均为 PASS 完成记录）
  List<LogEntry> _notes = const []; // 记录类型：全部书写记录（NOTE），按位置聚合进对应次
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = AppScope.of(context).repository;
    final item = await repo.getItem(widget.itemId);
    final all = item == null ? <LogEntry>[] : await repo.listLogs(widget.itemId);
    final isNote = item?.taskType == '记录';
    if (isNote) {
      _notes = all.where((e) => e.result == 'NOTE').toList();
    }
    final logs = all.where((e) => e.result == 'PASS').toList();
    if (!mounted) return;
    setState(() {
      _item = item;
      _logs = logs;
      _loading = false;
    });
  }

  /// 完成时刻文案：X年X月X日 XX时XX分（英文用 yyyy-MM-dd HH:mm）。
  String _when(AppLocalizations l10n, String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (l10n.localeName == 'zh') {
      return '${dt.year}年${dt.month}月${dt.day}日 $h时$m分';
    }
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd $h:$m';
  }

  /// 完成位置文案：正第X阶・第X级・第X次任务。
  String _pos(AppLocalizations l10n, LogEntry e) {
    final sep = l10n.localeName == 'zh' ? '・' : ' · ';
    final grade = ProgressEngine.gradeTitle(e.grade);
    final pos = '$grade$sep${l10n.levelPos(e.level + 1)}$sep${l10n.repPos(e.rep + 1)}';
    return l10n.localeName == 'zh' ? '$pos任务' : pos;
  }

  /// 该次（同阶/级/次位置）的全部书写记录。
  List<LogEntry> _notesOf(LogEntry pass) => _notes
      .where((n) => n.grade == pass.grade && n.level == pass.level && n.rep == pass.rep)
      .toList();

  Future<void> _openDetail(LogEntry pass) async {
    final isNote = _item?.taskType == '记录';
    // 记录类型：该次全部书写记录；事务类型：本次勾选的处理事项（每行一件事）。
    final contents = isNote
        ? _notesOf(pass).map((n) => n.note ?? '').toList()
        : (pass.note ?? '')
            .split('\n')
            .where((s) => s.trim().isNotEmpty)
            .toList();
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LogDetailPage(pass: pass, contents: contents),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNote = _item?.taskType == '记录';
    final isTask = _item?.taskType == '事务';
    final title = _item == null ? l10n.logsTitle : '${_item!.name} · ${l10n.logsTitle}';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? _Empty(l10n: l10n)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final e in _logs)
                      if (isNote || isTask)
                        _SessionCard(
                          when: _when(l10n, e.createdAt),
                          pos: _pos(l10n, e),
                          countLabel: isNote
                              ? l10n.noteInSession(_notesOf(e).length)
                              : l10n.handledInSession(
                                  (e.note ?? '')
                                      .split('\n')
                                      .where((s) => s.trim().isNotEmpty)
                                      .length),
                          onTap: () => _openDetail(e),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Text(
                            l10n.recordLine(_when(l10n, e.createdAt), _pos(l10n, e)),
                            style: const TextStyle(fontSize: 13, height: 1.6),
                          ),
                        ),
                  ],
                ),
    );
  }
}

/// 记录/事务类型的一次任务完成条目：位置 + 时间 + 内容计数，点击进该次回顾详情。
class _SessionCard extends StatelessWidget {
  final String when;
  final String pos;
  final String countLabel;
  final VoidCallback onTap;
  const _SessionCard({
    required this.when,
    required this.pos,
    required this.countLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pos,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(when,
                      style: const TextStyle(fontSize: 12, color: AppColors.mut)),
                ),
                Text(countLabel,
                    style: const TextStyle(fontSize: 12, color: AppColors.mut)),
                const SizedBox(width: 10),
                Text(l10n.logDetailOpen,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.acc)),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.acc),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final AppLocalizations l10n;
  const _Empty({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: AppColors.dim),
            const SizedBox(height: 12),
            Text(l10n.logsEmpty,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(l10n.logsEmptyHint,
                style: TextStyle(fontSize: 13, color: AppColors.mut)),
          ],
        ),
      ),
    );
  }
}
