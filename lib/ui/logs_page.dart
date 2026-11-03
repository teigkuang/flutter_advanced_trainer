/// 相关记录页：展示某任务全部完成记录（PASS），按时间倒序。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
