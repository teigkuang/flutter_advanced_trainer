/// 新建任务页：收集参数 → 校验 → 创建。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import '../l10n/app_localizations.dart';

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
  final _goal = TextEditingController();
  String _method = '运动';
  String _failRule = '停留';
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _grade.dispose();
    _begin.dispose();
    _plus.dispose();
    _beginG.dispose();
    _goal.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.errNameEmpty);
      return;
    }
    final grade = int.tryParse(_grade.text.trim());
    final begin = int.tryParse(_begin.text.trim());
    final plus = int.tryParse(_plus.text.trim());
    final beginG = int.tryParse(_beginG.text.trim());
    if (grade == null || begin == null || plus == null || beginG == null ||
        grade < 1 || begin < 0 || plus < 1 || beginG < 0) {
      _toast(l10n.errInvalidParams);
      return;
    }
    final repo = AppScope.of(context).repository;
    final items = await repo.listItems();
    if (items.any((e) => e.name == name)) {
      setState(() => _nameError = l10n.errNameExists);
      return;
    }
    setState(() => _nameError = null);
    final item = TrainingItem(
      name: name,
      trainingMethod: _method,
      goalText: _goal.text.trim(),
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
    _toast(l10n.toastCreated(name));
    Navigator.of(context).pop();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1600)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(l10n.fieldName, controller: _name, error: _nameError, hint: l10n.hintName),
          Row(
            children: [
              Expanded(child: _numField(l10n.fieldGrade, _grade)),
              const SizedBox(width: 12),
              Expanded(child: _numField(l10n.fieldBeginNum, _begin)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _numField(l10n.fieldPlus, _plus)),
              const SizedBox(width: 12),
              Expanded(child: _numField(l10n.fieldBeginGrade, _beginG)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _methodField(l10n)),
              const SizedBox(width: 12),
              Expanded(child: _failField(l10n)),
            ],
          ),
          const SizedBox(height: 2),
          _field(l10n.fieldGoal, controller: _goal, hint: l10n.hintGoal),
          const SizedBox(height: 6),
          FilledButton(onPressed: _submit, child: Text(l10n.submitCreate)),
        ],
      ),
    );
  }

  Widget _field(String label, {required TextEditingController controller, String? error, String? hint}) {
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
            decoration: InputDecoration(errorText: error, hintText: hint),
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

  Widget _methodField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(l10n.fieldMethod, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          DropdownButtonFormField<String>(
            initialValue: _method,
            items: [
              DropdownMenuItem(value: '运动', child: Text(l10n.methodSport)),
              DropdownMenuItem(value: '学习', child: Text(l10n.methodStudy)),
              DropdownMenuItem(value: '任务', child: Text(l10n.methodTask)),
              DropdownMenuItem(value: '其他', child: Text(l10n.methodOther)),
            ],
            onChanged: (v) => setState(() => _method = v!),
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }

  Widget _failField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(l10n.fieldFailRule, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          DropdownButtonFormField<String>(
            initialValue: _failRule,
            items: [
              DropdownMenuItem(value: '停留', child: Text(l10n.failStay)),
              DropdownMenuItem(value: '回退', child: Text(l10n.failRecede)),
            ],
            onChanged: (v) => setState(() => _failRule = v!),
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}
