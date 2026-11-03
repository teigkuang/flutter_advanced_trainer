/// 核心算法：金字塔式递进数字序列生成 + 进度状态机。
///
/// 这是 `advanced-trainer`(Java `ProgressEngine`) 的 Dart 移植版。
/// Java 仓为算法权威维护源，两处保持同步（共享测试向量见 test/engine_test.dart）。
/// 逻辑与原 Grader.jar 的 getGradingForm 一致：
///   - 逐"阶"逐"级"生成"先升后降"的数字金字塔序列；
///   - 偶数阶峰顶单峰（准第），奇数阶峰顶双峰（正第）；
///   - 在此之上增加"进度状态机"，把静态表格升级为可推进、可查询的训练进度。
library;

import 'models.dart';

class ProgressEngine {
  /// 内部阶号 grade 的段标题：偶数=准第 c 阶，奇数=正第 c 阶。
  static String gradeTitle(int grade) {
    final c = grade ~/ 2;
    return (grade % 2 == 0) ? '准第$c阶' : '正第$c阶';
  }

  /// 第 grade 阶包含的级数 = c+1。
  static int levelCount(int grade) => grade ~/ 2 + 1;

  /// 第 grade 阶的任一级需完成的次数 = grade+1。
  static int repCount(int grade) => grade + 1;

  /// 生成第 (grade, level) 的金字塔序列。
  ///   c = grade/2；base(m) = A + (m+level)*P
  ///   偶数阶：base(0..c) + base(c-1..0)   （峰顶单峰）
  ///   奇数阶：base(0..c) + base(c..0)     （峰顶双峰）
  /// 序列长度恒为 grade+1。
  static List<int> buildSeq(int A, int P, int grade, int level) {
    final r = <int>[];
    final c = grade ~/ 2;
    for (int m = 0; m <= c; m++) {
      r.add(A + (m + level) * P);
    }
    if (grade % 2 == 0) {
      for (int m = c - 1; m >= 0; m--) {
        r.add(A + (m + level) * P);
      }
    } else {
      for (int m = c; m >= 0; m--) {
        r.add(A + (m + level) * P);
      }
    }
    return r;
  }

  /// 将序列数字转为 "(1)(2)(3)(3)(2)(1)" 形式文本。
  static String seqToString(List<int> s) => s.map((v) => '($v)').join();

  /// 解析 "(1)(2)(3)(2)(1)" 形式文本回数字列表。
  static List<int> parseSeq(String text) {
    final r = <int>[];
    if (text.isEmpty) return r;
    final re = RegExp(r'\((\d+)\)');
    for (final m in re.allMatches(text)) {
      r.add(int.parse(m.group(1)!));
    }
    return r;
  }

  /// 训练项初始进度位置：起点阶的首级首次。
  static ProgressState initialState(TrainingItem item) =>
      ProgressState(item.beginGrade - 1, 0, 0);

  /// 通过(pass)后推进一次：
  ///   rep+1；该级次数满 → level+1、次数清零；该阶级满 → grade+1、级/次数清零。
  /// 返回新状态；整个训练完成时返回 null。
  static ProgressState? advance(TrainingItem item, ProgressState st) {
    int grade = st.grade, level = st.level, rep = st.rep;
    rep++;
    if (rep >= repCount(grade)) {
      rep = 0;
      level++;
      if (level >= levelCount(grade)) {
        level = 0;
        grade++;
        if (grade >= item.dGrade) return null; // 全部完成
      }
    }
    return ProgressState(grade, level, rep);
  }

  /// 未通过(fail)后的规则：
  ///   STAY   —— 停留原地（默认，稳妥）；
  ///   RECEDE —— 回退一次（级内回退；级首则回上一级末次；阶首则回上一阶末级末次）。
  static ProgressState recede(TrainingItem item, ProgressState st) {
    if (item.failRule.toUpperCase() != 'RECEDE') return st; // STAY
    int grade = st.grade, level = st.level, rep = st.rep;
    if (rep > 0) {
      rep--;
    } else if (level > 0) {
      level--;
      rep = repCount(grade) - 1;
    } else if (grade > item.beginGrade - 1) {
      grade--;
      level = levelCount(grade) - 1;
      rep = repCount(grade) - 1;
    } else {
      return st; // 已在起点，无法回退
    }
    return ProgressState(grade, level, rep);
  }

  /// 当前位置文字描述，如：正第2阶 · 第3级 · 第2次。
  static String position(TrainingItem item, ProgressState st) =>
      '${gradeTitle(st.grade)} · 第${st.level + 1}级 · 第${st.rep + 1}次';

  /// 从起点累计已完成的次数（首页卡片"已完成 N 次"）。
  ///  = Σ(起点阶..当前阶-1 每阶全级次数) + 当前级已完成次数 + 当前次已完成次数。
  /// 起点为 initialState（beginGrade-1, 0, 0）；未完成过任何一次时为 0。
  static int totalCompleted(TrainingItem item, ProgressState st) {
    int total = 0;
    for (int g = item.beginGrade - 1; g < st.grade; g++) {
      total += levelCount(g) * repCount(g);
    }
    total += st.level * repCount(st.grade) + st.rep;
    return total;
  }

  /// 由当前进度推算"正在进行的那一次"的完整数据（纯计算，不写库）。
  static RepData currentRepData(TrainingItem item, ProgressState st) {
    return RepData(
      grade: st.grade,
      level: st.level,
      rep: st.rep,
      title: position(item, st),
      sequence: buildSeq(item.beginNum, item.plusVar, st.grade, st.level),
      levelNeed: repCount(st.grade),
      levelDone: st.rep,
      levelLeft: repCount(st.grade) - st.rep,
    );
  }
}
