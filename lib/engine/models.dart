/// 进阶训练器 · 数据模型
///
/// 与算法仓 `advanced-trainer`(Java) 的字段/概念严格对齐：
///   阶(grade) → 级(level) → 次(rep)，均为 0 起始内部编号。
library;

/// 进度位置（阶/级/次，0 起始）。
class ProgressState {
  final int grade;
  final int level;
  final int rep;

  const ProgressState(this.grade, this.level, this.rep);

  @override
  bool operator ==(Object other) =>
      other is ProgressState && other.grade == grade && other.level == level && other.rep == rep;

  @override
  int get hashCode => Object.hash(grade, level, rep);

  @override
  String toString() => 'ProgressState($grade,$level,$rep)';
}

/// 当前正在进行的那一次的推算数据（纯计算，不落库）。
/// 注：产品需求已明确不在界面展示"段和"，故此处不暴露 segmentSum。
class RepData {
  final int grade;
  final int level;
  final int rep;
  final String title; // 显示标题，如 正第2阶 · 第1级 · 第4次
  final List<int> sequence; // 本次应做的金字塔序列
  final int levelNeed; // 本级共需次数
  final int levelDone; // 本级已完成次数
  final int levelLeft; // 本级剩余次数

  const RepData({
    required this.grade,
    required this.level,
    required this.rep,
    required this.title,
    required this.sequence,
    required this.levelNeed,
    required this.levelDone,
    required this.levelLeft,
  });
}

/// 训练项（对应 training_item 表）。
class TrainingItem {
  int? id;
  String name;
  String taskType; // 任务类型：运动 / 事务 / 学习 / 记录（替换原 trainingMethod 选项语义）
  String trainingMethod; // 旧字段（训练方式），兼容旧数据迁移；新数据写入与 taskType 一致
  String goalText; // 具体实施目标（执行页提示）
  String metricUnit; // 数字代表单位（旧字段，已停用：显示层由"训练方式"取代）
  String listFilePath; // 事务/学习：清单文件在应用文档目录的路径（无则空）
  String listFileName; // 事务/学习：清单文件原始文件名（无则空）
  int beginNum; // A 起始数
  int plusVar; // P 增加量
  int dGrade; // G 内部阶数基准（显示层"阶数" = dGrade/2 - 1）
  int beginGrade; // B 内部起始阶基准（显示层"起始阶数" = (beginGrade-1)/2）
  int bpm; // 运动：节拍器 BPM（40~208，默认 120；创建/执行/编辑三处读写，最终一致）
  int listCursor; // 事务/学习：全局清单游标（学习子页整项完成时推进并持久化，下次执行从此继续）
  String failRule; // STAY 停留 / RECEDE 回退
  String status; // ACTIVE / DONE
  String createdAt; // yyyy-MM-dd

  TrainingItem({
    this.id,
    required this.name,
    this.taskType = '运动',
    this.trainingMethod = '运动',
    this.goalText = '',
    this.metricUnit = '',
    this.listFilePath = '',
    this.listFileName = '',
    required this.beginNum,
    required this.plusVar,
    required this.dGrade,
    required this.beginGrade,
    this.bpm = 120,
    this.listCursor = 0,
    this.failRule = 'STAY',
    this.status = 'ACTIVE',
    required this.createdAt,
  });

  /// 显示层"阶数"。
  int get displayGrade => dGrade ~/ 2 - 1;

  /// 显示层"起始阶数"。
  int get displayBeginGrade => (beginGrade - 1) ~/ 2;

  /// 由显示层参数构造内部基准。
  static int dGradeFromDisplay(int g) => g * 2 + 2;
  static int beginGradeFromDisplay(int b) => b * 2 + 1;
}

/// 完成日志（对应 completion_log 表）。
class LogEntry {
  int? id;
  int itemId;
  String logDate;
  int grade;
  int level;
  int rep;
  String target; // 目标序列文本
  String result; // PASS / FAIL
  String? note;
  String createdAt;

  LogEntry({
    this.id,
    required this.itemId,
    required this.logDate,
    required this.grade,
    required this.level,
    required this.rep,
    required this.target,
    required this.result,
    this.note,
    required this.createdAt,
  });
}
