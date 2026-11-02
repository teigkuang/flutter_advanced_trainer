/// 详情页（当前任务）：展示当前位置、本次序列、本级进度。
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import 'execute_page.dart';
import 'theme.dart';

class DetailPage extends StatefulWidget {
  final int itemId;
  const DetailPage({super.key, required this.itemId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TrainingItem? _item;
  RepData? _data;
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
    final data = ProgressEngine.currentRepData(item, pr);
    if (!mounted) return;
    setState(() {
      _item = item;
      _data = data;
      _loading = false;
    });
  }

  Future<void> _goExecute() async {
    if (_item == null) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ExecutePage(item: _item!, startState: _data!),
    ));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('任务详情')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_item == null || _data == null)
              ? const Center(child: Text('任务不存在'))
              : _body(),
    );
  }

  Widget _body() {
    final item = _item!;
    final d = _data!;
    final done = item.status == 'DONE';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(item.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            _Pill(done: done),
          ],
        ),
        const SizedBox(height: 14),
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
              Text.rich(TextSpan(children: [
                TextSpan(text: d.title.split(' · ').take(1).join()),
                const TextSpan(text: ' · ', style: TextStyle(color: AppColors.acc)),
                TextSpan(text: d.title.split(' · ').skip(1).join(' · ')),
              ]), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text('单位：${item.metricUnit}',
                  style: const TextStyle(fontSize: 12, color: AppColors.mut)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('本次序列 · 共 ${d.sequence.length} 项',
            style: const TextStyle(fontSize: 12, color: AppColors.mut)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            ProgressEngine.seqToString(d.sequence),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
                color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text('本级进度：已完成 ${d.levelDone} / 共需 ${d.levelNeed} 次',
            style: const TextStyle(fontSize: 13, color: AppColors.mut)),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: done ? null : _goExecute,
          child: Text(done ? '已完成' : '确认继续执行'),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final bool done;
  const _Pill({required this.done});

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.ok : AppColors.acc;
    final bg = done ? AppColors.okSoft : AppColors.accSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(done ? '已完成' : '训练中',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
