/// 记录详情页：展示某笔书写记录（记录类型任务）的完整内容、所属完成位置与时间。
/// 仅记录类型任务可进入（点击相关记录页的记录项）；其他类型无此详情页。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

class LogDetailPage extends StatelessWidget {
  final LogEntry entry;
  const LogDetailPage({super.key, required this.entry});

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

  String _pos(AppLocalizations l10n, LogEntry e) {
    final sep = l10n.localeName == 'zh' ? '・' : ' · ';
    final grade = ProgressEngine.gradeTitle(e.grade);
    return '$grade$sep${l10n.levelPos(e.level + 1)}$sep${l10n.repPos(e.rep + 1)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.logDetailTitle)),
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
                Text(l10n.logDetailContentLabel,
                    style: const TextStyle(fontSize: 12, color: AppColors.mut)),
                const SizedBox(height: 8),
                SelectableText(entry.note ?? '',
                    style: const TextStyle(fontSize: 15, height: 1.7)),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                _row(l10n.logDetailPosLabel, _pos(l10n, entry)),
                const SizedBox(height: 10),
                _row(l10n.logDetailTimeLabel, _when(l10n, entry.createdAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.mut)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
