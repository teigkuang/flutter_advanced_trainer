/// 新建任务页：收集参数 → 校验 → 创建。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/models.dart';
import '../engine/progress_engine.dart';
import 'app_scope.dart';
import 'theme.dart';
import '../l10n/app_localizations.dart';

class CreatePage extends StatefulWidget {
  /// 编辑模式传入待编辑任务（预填、提交走更新、保留进度）；新建传 null。
  final TrainingItem? item;
  const CreatePage({super.key, this.item});

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
  late String _method = widget.item?.trainingMethod ?? '运动';
  late String _failRule = widget.item?.failRule == 'RECEDE' ? '回退' : '停留';
  String? _nameError;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    if (it != null) {
      _name.text = it.name;
      _grade.text = '${it.displayGrade}';
      _begin.text = '${it.beginNum}';
      _plus.text = '${it.plusVar}';
      _beginG.text = '${it.displayBeginGrade}';
      _goal.text = it.goalText;
    }
  }

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
    if (items.any((e) => e.name == name && !(_isEdit && e.id == widget.item!.id))) {
      setState(() => _nameError = l10n.errNameExists);
      return;
    }
    setState(() => _nameError = null);
    final failRule = _failRule == '回退' ? 'RECEDE' : 'STAY';
    if (_isEdit) {
      final src = widget.item!;
      final updated = TrainingItem(
        id: src.id,
        name: name,
        trainingMethod: _method,
        goalText: _goal.text.trim(),
        metricUnit: src.metricUnit,
        beginNum: begin,
        plusVar: plus,
        dGrade: TrainingItem.dGradeFromDisplay(grade),
        beginGrade: TrainingItem.beginGradeFromDisplay(beginG),
        failRule: failRule,
        status: src.status,
        createdAt: src.createdAt,
      );
      await repo.updateItem(updated); // 保留既有进度，不重置
      if (!mounted) return;
      _toast(l10n.toastSaved(name));
      Navigator.of(context).pop(true);
      return;
    }
    final item = TrainingItem(
      name: name,
      trainingMethod: _method,
      goalText: _goal.text.trim(),
      beginNum: begin,
      plusVar: plus,
      dGrade: TrainingItem.dGradeFromDisplay(grade),
      beginGrade: TrainingItem.beginGradeFromDisplay(beginG),
      failRule: failRule,
      status: 'ACTIVE',
      createdAt: DateTime.now().toIso8601String().substring(0, 10),
    );
    final id = await repo.createItem(item);
    await repo.saveProgress(id, ProgressEngine.initialState(item));
    if (!mounted) return;
    _toast(l10n.toastCreated(name));
    Navigator.of(context).pop(true);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1600)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.editTitle : l10n.createTitle)),
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
          FilledButton(onPressed: _submit,
              child: Text(_isEdit ? l10n.submitEdit : l10n.submitCreate)),
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

  /// 自绘下拉：与父输入框同宽的白底灰线圆角边框；
  /// 弹出面板纯白底、灰线圆角，宽度窄于编辑框，紧贴编辑框正下方左对齐展开。
  Widget _appDropdown(
    String label,
    List<MapEntry<String, String>> options,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          // Builder 提供编辑框自身的 BuildContext，_openMenu 用它取 RenderBox 定位，
          // 使弹窗紧贴本编辑框正下方（而非页面级坐标）
          Builder(
            builder: (menuCtx) => GestureDetector(
              onTap: () => _openMenu(menuCtx, options, value, onChanged),
              child: Container(
                width: double.infinity, // 与父输入框同宽
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(value,
                          style: const TextStyle(fontSize: 14, color: AppColors.ink),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.mut),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMenu(
    BuildContext context,
    List<MapEntry<String, String>> options,
    String value,
    ValueChanged<String> onChanged,
  ) async {
    // context 为编辑框自身（Builder 传入），取其 RenderBox 定位
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final pos = box.localToGlobal(Offset.zero);
    final overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final tl = overlay.globalToLocal(pos);
    final screenW = MediaQuery.of(context).size.width;
    // 面板宽：略窄于编辑框（紧贴其下、留少量空隙），并在窄屏时自适应避免越界
    final panelW = (size.width - 12).clamp(120.0, 240.0);
    final left = (tl.dx + panelW > screenW - 16) ? (screenW - panelW - 16) : tl.dx;
    final rel = RelativeRect.fromLTRB(
      left,
      tl.dy + size.height, // 紧贴编辑框底部
      left + panelW,
      tl.dy + size.height + 320,
    );
    final sel = await showMenu<String>(
      context: context,
      position: rel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.line),
      ),
      items: [
        for (final o in options)
          PopupMenuItem<String>(
            value: o.key,
            child: SizedBox(
              width: panelW - 32,
              child: Text(o.value, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
    );
    if (sel != null && sel != value) onChanged(sel);
  }

  Widget _methodField(AppLocalizations l10n) {
    return _appDropdown(
      l10n.fieldMethod,
      [
        const MapEntry('运动', '运动'),
        const MapEntry('学习', '学习'),
        const MapEntry('任务', '任务'),
        const MapEntry('其他', '其他'),
      ],
      _method,
      (v) => setState(() => _method = v),
    );
  }

  Widget _failField(AppLocalizations l10n) {
    return _appDropdown(
      l10n.fieldFailRule,
      [
        const MapEntry('停留', '停留'),
        const MapEntry('回退', '回退'),
      ],
      _failRule,
      (v) => setState(() => _failRule = v),
    );
  }
}
