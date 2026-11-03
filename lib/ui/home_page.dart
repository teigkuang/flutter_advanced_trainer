/// 列表页（首页）：展示所有训练任务 + 当前进度概要。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import 'create_page.dart';
import 'detail_page.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<_CardData> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context)!;
    final repo = AppScope.of(context).repository;
    final items = await repo.listItems();
    final cards = <_CardData>[];
    for (final it in items) {
      final pr = await repo.getProgress(it.id!) ?? ProgressEngine.initialState(it);
      final started = !(pr.grade == it.beginGrade - 1 && pr.level == 0 && pr.rep == 0);
      cards.add(_CardData(
        item: it,
        done: it.status == 'DONE',
        wait: !started,
        gradeText: started ? ProgressEngine.gradeTitle(pr.grade) : '',
        levelText: started ? l10n.levelPos(pr.level + 1) : '',
      ));
    }
    if (!mounted) return;
    setState(() {
      _cards..clear()..addAll(cards);
      _loading = false;
    });
  }

  Future<void> _openCreate() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreatePage()));
    _load();
  }

  Future<void> _openDetail(int id) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => DetailPage(itemId: id)));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(AppLocalizations.of(context)!.appSlogan,
                style: const TextStyle(fontSize: 10, letterSpacing: 1, color: Color(0xFFc9c2b6))),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _openCreate,
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppLocalizations.of(context)!.newTask),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_cards.isEmpty) {
      return _Empty(onCreate: _openCreate);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final c in _cards)
          _TaskCard(
            data: c,
            onTap: () => _openDetail(c.item.id!),
          ),
      ],
    );
  }
}

class _CardData {
  final TrainingItem item;
  final bool done;
  final bool wait;
  final String gradeText;
  final String levelText;
  const _CardData({
    required this.item,
    required this.done,
    required this.wait,
    required this.gradeText,
    required this.levelText,
  });
}

class _TaskCard extends StatelessWidget {
  final _CardData data;
  final VoidCallback onTap;
  const _TaskCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                Expanded(
                  child: Text(data.item.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                _StatusPill(done: data.done, wait: data.wait),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              data.wait
                  ? l10n.statusWait
                  : l10n.achievedText(data.gradeText, data.levelText),
              style: const TextStyle(fontSize: 12, color: AppColors.mut),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool done;
  final bool wait;
  const _StatusPill({required this.done, required this.wait});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = done ? AppColors.ok : (wait ? AppColors.mut : AppColors.acc);
    final bg = done ? AppColors.okSoft : (wait ? AppColors.dim : AppColors.accSoft);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(done ? l10n.statusDone : (wait ? l10n.statusWait : l10n.statusActive),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onCreate;
  const _Empty({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_outlined, size: 48, color: AppColors.dim),
            const SizedBox(height: 12),
            Text(l10n.emptyTitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(l10n.emptySubtitle,
                style: TextStyle(fontSize: 13, color: AppColors.mut)),
            const SizedBox(height: 18),
            FilledButton(onPressed: onCreate, child: Text(l10n.emptyCta)),
          ],
        ),
      ),
    );
  }
}
