/// 新建任务页：收集参数 → 校验 → 创建。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _name = TextEditingController();
  final _grade = TextEditingController(text: '3');
  final _begin = TextEditingController(text: '1');
  final _plus = TextEditingController(text: '1');
  final _beginG = TextEditingController(text: '0');
  String _unit = '次';
  String _failRule = '停留';
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _grade.dispose();
    _begin.dispose();
    _plus.dispose();
    _beginG.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = '请填写名称');
      return;
    }
    final grade = int.tryParse(_grade.text.trim());
    final begin = int.tryParse(_begin.text.trim());
    final plus = int.tryParse(_plus.text.trim());
    final beginG = int.tryParse(_beginG.text.trim());
    if (grade == null || begin == null || plus == null || beginG == null ||
        grade < 1 || begin < 0 || plus < 1 || beginG < 0) {
      _toast('请填写合法数值：阶数≥1，起始数/起始阶数≥0，增加量≥1');
      return;
    }
    final repo = AppScope.of(context).repository;
    final items = await repo.listItems();
    if (items.any((e) => e.name == name)) {
      setState(() => _nameError = '名称已存在');
      return;
    }
    setState(() => _nameError = null);
    final item = TrainingItem(
      name: name,
      metricUnit: _unit,
      beginNum: begin,
      plusVar: plus,
      dGrade: TrainingItem.dGradeFromDisplay(grade),
      beginGrade: TrainingItem.beginGradeFromDisplay(beginG),
      failRule: _failRule == '回退' ? 'RECEDE' : 'STAY',
      status: 'ACTIVE',
      createdAt: DateTime.now().toIso8601String().substring(0, 10),
    );
    final id = await repo.createItem(item);
    await repo.saveProgress(id, ProgressEngine.initialState(item));
    if (!mounted) return;
    _toast('已创建「$name」');
    Navigator.of(context).pop();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1600)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新建训练任务')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('训练项名称 *', controller: _name, error: _nameError),
          Row(
            children: [
              Expanded(child: _numField('阶数 *', _grade)),
              const SizedBox(width: 12),
              Expanded(child: _numField('起始数 *', _begin)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _numField('增加量 *', _plus)),
              const SizedBox(width: 12),
              Expanded(child: _numField('起始阶数 *', _beginG)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _unitField()),
              const SizedBox(width: 12),
              Expanded(child: _failField()),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('提交 · 创建任务')),
        ],
      ),
    );
  }

  Widget _field(String label, {required TextEditingController controller, String? error}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          TextField(
            controller: controller,
            onChanged: (_) {
              if (error != null) setState(() => _nameError = null);
            },
            decoration: InputDecoration(errorText: error, hintText: '如：胸肌卧推'),
          ),
        ],
      ),
    );
  }

  Widget _numField(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          TextField(
            controller: c,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Widget _unitField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 6),
            child: Text('单位', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          DropdownButtonFormField<String>(
            initialValue: _unit,
            items: const [
              DropdownMenuItem(value: '次', child: Text('次')),
              DropdownMenuItem(value: '个', child: Text('个')),
              DropdownMenuItem(value: 'kg', child: Text('kg')),
            ],
            onChanged: (v) => setState(() => _unit = v!),
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }

  Widget _failField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 6),
            child: Text('未完成规则', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          DropdownButtonFormField<String>(
            initialValue: _failRule,
            items: const [
              DropdownMenuItem(value: '停留', child: Text('停留')),
              DropdownMenuItem(value: '回退', child: Text('回退')),
            ],
            onChanged: (v) => setState(() => _failRule = v!),
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}
