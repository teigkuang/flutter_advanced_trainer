/// 记录详情页：展示记录类型任务"某一次任务完成"的综合记录。
///
/// 由相关记录页点击某次（PASS 完成记录）进入；展示该次所属位置、完成时间，
/// 以及该次（同阶/级/次位置）的全部书写记录内容，综合到一起。
/// 仅记录类型任务可进入；其他类型无此详情页。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

class LogDetailPage extends StatelessWidget {
  final LogEntry pass; // 该次完成记录（PASS）
  final List<LogEntry> notes; // 该次全部书写记录（NOTE）
  const LogDetailPage({super.key, required this.pass, required this.notes});

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
                Text(l10n.logDetailPosLabel,
                    style: const TextStyle(fontSize: 12, color: AppColors.mut)),
                const SizedBox(height: 8),
                Text('${_pos(l10n, pass)}任务',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _row(l10n.logDetailTimeLabel, _when(l10n, pass.createdAt)),
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
                Row(
                  children: [
                    Text(l10n.logDetailContentLabel,
                        style: const TextStyle(fontSize: 12, color: AppColors.mut)),
                    const Spacer(),
                    Text(l10n.noteInSession(notes.length),
                        style: const TextStyle(fontSize: 12, color: AppColors.mut)),
                  ],
                ),
                const SizedBox(height: 8),
                if (notes.isEmpty)
                  Text(l10n.logsEmpty,
                      style: const TextStyle(fontSize: 13, color: AppColors.mut))
                else
                  for (int i = 0; i < notes.length; i++) ...[
                    if (i > 0)
                      Divider(height: 24, color: AppColors.line),
                    SelectableText(
                      notes[i].note ?? '',
                      style: const TextStyle(fontSize: 15, height: 1.7),
                    ),
                  ],
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
