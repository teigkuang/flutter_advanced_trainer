/// 列表页（首页）：展示所有训练任务 + 当前进度概要。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import 'create_page.dart';
import 'detail_page.dart';
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
    final repo = AppScope.of(context).repository;
    final items = await repo.listItems();
    final cards = <_CardData>[];
    for (final it in items) {
      final pr = await repo.getProgress(it.id!) ?? ProgressEngine.initialState(it);
      final d = ProgressEngine.currentRepData(it, pr);
      cards.add(_CardData(
        item: it,
        done: it.status == 'DONE',
        title: d.title,
        seq: ProgressEngine.seqToString(d.sequence),
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('进阶训练器', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('撕裂壁垒 · 含泪上行',
                style: TextStyle(fontSize: 10, letterSpacing: 1, color: Color(0xFFc9c2b6))),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _openCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建任务'),
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
  final String title;
  final String seq;
  const _CardData({required this.item, required this.done, required this.title, required this.seq});
}

class _TaskCard extends StatelessWidget {
  final _CardData data;
  final VoidCallback onTap;
  const _TaskCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                _StatusPill(done: data.done),
              ],
            ),
            const SizedBox(height: 7),
            Text(data.title,
                style: const TextStyle(fontSize: 12, color: AppColors.mut)),
            const SizedBox(height: 9),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(data.seq,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool done;
  const _StatusPill({required this.done});

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.ok : AppColors.acc;
    final bg = done ? AppColors.okSoft : AppColors.accSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(done ? '已完成' : '训练中',
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_outlined, size: 48, color: AppColors.dim),
            const SizedBox(height: 12),
            const Text('还没有训练任务',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('创建第一个训练项，从第 1 级开始逐步突破',
                style: TextStyle(fontSize: 13, color: AppColors.mut)),
            const SizedBox(height: 18),
            FilledButton(onPressed: onCreate, child: const Text('新建第一个训练任务')),
          ],
        ),
      ),
    );
  }
}
