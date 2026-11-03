/// 展示层本地化格式化：位置标题。
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
