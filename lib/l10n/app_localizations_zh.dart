// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '进阶训练器';

  @override
  String get appSlogan => '撕裂壁垒 · 努力进取';

  @override
  String get newTask => '新建任务';

  @override
  String get emptyTitle => '还没有训练任务';

  @override
  String get emptySubtitle => '创建第一个训练项，从第 1 级开始逐步突破';

  @override
  String get emptyCta => '新建第一个训练任务';

  @override
  String get statusDone => '已完成';

  @override
  String get statusActive => '训练中';

  @override
  String get statusWait => '待开始';

  @override
  String get createTitle => '新建训练任务';

  @override
  String get fieldName => '训练项名称 *';

  @override
  String get fieldGrade => '阶数 *';

  @override
  String get fieldBeginNum => '起始数 *';

  @override
  String get fieldPlus => '增加量 *';

  @override
  String get fieldBeginGrade => '起始阶数 *';

  @override
  String get fieldMethod => '训练方式';

  @override
  String get fieldGoal => '具体实施目标';

  @override
  String get fieldFailRule => '未完成规则';

  @override
  String get hintName => '如：胸肌卧推';

  @override
  String get hintGoal => '如：每日 50 个俯卧撑，每组间隔 1 分钟';

  @override
  String get errNameEmpty => '请填写名称';

  @override
  String get errNameExists => '名称已存在';

  @override
  String get errInvalidParams => '请填写合法数值：阶数≥1，起始数/起始阶数≥0，增加量≥1';

  @override
  String get submitCreate => '提交 · 创建任务';

  @override
  String toastCreated(String name) {
    return '已创建「$name」';
  }

  @override
  String get methodSport => '运动';

  @override
  String get methodStudy => '学习';

  @override
  String get methodTask => '任务';

  @override
  String get methodOther => '其他';

  @override
  String get failStay => '停留';

  @override
  String get failRecede => '回退';

  @override
  String achievedCount(int n) {
    return '已完成 $n 次';
  }

  @override
  String get detailTitle => '任务详情';

  @override
  String get taskNotFound => '任务不存在';

  @override
  String methodLabel(String method) {
    return '训练方式：$method';
  }

  @override
  String goalHint(String goal) {
    return '具体实施目标：$goal';
  }

  @override
  String seqCount(int count) {
    return '本次序列 · 共 $count 项';
  }

  @override
  String levelProgress(int done, int need) {
    return '本级进度：已完成 $done / 共需 $need 次';
  }

  @override
  String get confirmContinue => '确认继续执行';

  @override
  String get executeTitle => '执行任务';

  @override
  String get todayTarget => '本次要完成';

  @override
  String checkedCount(int done, int total) {
    return '已勾选 $done / $total 项';
  }

  @override
  String get confirmDone => '确认完成';

  @override
  String get markFail => '标记未完成';

  @override
  String itemIndex(int index) {
    return '第 $index 项';
  }

  @override
  String get toastDoneFinish => '全部完成，已收官';

  @override
  String get toastAdvance => '已完成并晋级';

  @override
  String toastFail(String rule) {
    return '已标记未完成 · $rule';
  }

  @override
  String gradePosEven(int n) {
    return '准第$n阶';
  }

  @override
  String gradePosOdd(int n) {
    return '正第$n阶';
  }

  @override
  String levelPos(int n) {
    return '第$n级';
  }

  @override
  String repPos(int n) {
    return '第$n次';
  }
}
