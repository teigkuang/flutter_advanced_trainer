/// 任务管理页（首页长按进入）：编辑 / 删除 / 查看相关记录。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import 'create_page.dart';
import 'logs_page.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

class ManagePage extends StatefulWidget {
  final int itemId;
  const ManagePage({super.key, required this.itemId});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  TrainingItem? _item;
  bool _wait = false;
  bool _done = false;
  int? _achGrade;
  int? _achLevel;
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
    if (item == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final pr = await repo.getProgress(widget.itemId) ?? ProgressEngine.initialState(item);
    final ach = ProgressEngine.achievedPosition(item, pr);
    if (!mounted) return;
    setState(() {
      _item = item;
      _done = item.status == 'DONE';
      _wait = ach == null;
      _achGrade = ach?.$1;
      _achLevel = ach?.$2;
      _loading = false;
    });
  }

  Future<void> _goEdit() async {
    if (_item == null) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CreatePage(item: _item!),
    ));
    _load();
  }

  Future<void> _goLogs() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LogsPage(itemId: widget.itemId)));
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = AppScope.of(context).repository;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.deleteTitle),
        content: Text(l10n.deleteWarn),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(l10n.deleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.deleteConfirm),
          ),
        ],
      ),
    );
    if (ok != true || _item == null) return;
    final name = _item!.name;
    await repo.deleteItem(widget.itemId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.toastDeleted(name)),
      duration: const Duration(milliseconds: 1600),
    ));
    Navigator.of(context).pop(true); // 回首页并刷新
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_item == null)
              ? Center(child: Text(l10n.taskNotFound))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _header(l10n),
                    const SizedBox(height: 18),
                    _Entry(
                      icon: Icons.edit_outlined,
                      label: l10n.manageEdit,
                      color: AppColors.acc,
                      onTap: _goEdit,
                    ),
                    _Entry(
                      icon: Icons.receipt_long_outlined,
                      label: l10n.manageLogs,
                      color: AppColors.acc,
                      onTap: _goLogs,
                    ),
                    _Entry(
                      icon: Icons.delete_outline,
                      label: l10n.manageDelete,
                      color: AppColors.danger,
                      onTap: _confirmDelete,
                    ),
                  ],
                ),
    );
  }

  Widget _header(AppLocalizations l10n) {
    final item = _item!;
    final color = _done ? AppColors.ok : (_wait ? AppColors.mut : AppColors.acc);
    final bg = _done ? AppColors.okSoft : (_wait ? AppColors.dim : AppColors.accSoft);
    return Container(
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
              _TypePill(type: item.taskType),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  _done ? l10n.statusDone : (_wait ? l10n.statusWait : l10n.statusActive),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _wait
                ? l10n.statusWait
                : l10n.achievedText(
                    ProgressEngine.gradeTitle(_achGrade!),
                    l10n.levelPos(_achLevel! + 1),
                  ),
            style: const TextStyle(fontSize: 12, color: AppColors.mut),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String type;
  const _TypePill({required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (type) {
      '事务' => l10n.typeTask,
      '学习' => l10n.typeStudy,
      '记录' => l10n.typeRecord,
      _ => l10n.typeSport,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.mut)),
    );
  }
}

class _Entry extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Entry({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mut),
            ],
          ),
        ),
      ),
    );
  }
}
