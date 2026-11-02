/// 展示层本地化格式化：位置标题、单位映射。
library;

import '../engine/models.dart';
import '../l10n/app_localizations.dart';

/// 由 RepData 的数值（阶/级/次）按当前语言构建位置标题，
/// 例：中文「正第2阶 · 第1级 · 第4次」，英文「Stage 2 · Level 1 · Rep 4」。
String localizedPosition(AppLocalizations l10n, RepData d) {
  final even = d.grade % 2 == 0;
  final stage = d.grade ~/ 2;
  final grade = even ? l10n.gradePosEven(stage) : l10n.gradePosOdd(stage);
  return '$grade · ${l10n.levelPos(d.level + 1)} · ${l10n.repPos(d.rep + 1)}';
}

/// 将存储的单位码映射为当前语言的单位显示文本。
String localizedUnit(AppLocalizations l10n, String unit) {
  switch (unit) {
    case '次':
      return l10n.unitReps;
    case '个':
      return l10n.unitPieces;
    case 'kg':
      return l10n.unitKg;
    default:
      return unit;
  }
}
