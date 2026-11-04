/// 相关记录页：展示某任务完成记录。
///
/// 任务类型分支（第五轮定稿）：
///   - 其他类型：PASS 完成记录，文案含完成时间与完成位置，不跳详情。
///   - 记录类型：每条 = 一笔书写记录，展示内容（截断摘要）+时间，点击 → 记录详情页；
///     PASS 晋级完成记录仍以文案展示、不可点。
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
  List<LogEntry> _logs = const [];
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
    final logs = all
        .where((e) => isNote ? (e.result == 'NOTE' || e.result == 'PASS') : e.result == 'PASS')
        .toList();
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

  Future<void> _openDetail(LogEntry e) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LogDetailPage(entry: e)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNote = _item?.taskType == '记录';
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
                      if (isNote && e.result == 'NOTE')
                        _NoteCard(
                          summary: e.note ?? '',
                          when: _when(l10n, e.createdAt),
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

/// 记录类型的一笔书写记录：内容摘要 + 时间，点击进记录详情页。
class _NoteCard extends StatelessWidget {
  final String summary;
  final String when;
  final VoidCallback onTap;
  const _NoteCard({required this.summary, required this.when, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firstLine = summary.replaceAll('\n', ' ').trim();
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
            Text(firstLine,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.article_outlined, size: 14, color: AppColors.mut),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(when,
                      style: const TextStyle(fontSize: 12, color: AppColors.mut)),
                ),
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
