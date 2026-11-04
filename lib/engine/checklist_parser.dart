/// 清单 / 学习资料文件解析（草案，PRD §4.7.2）
///
/// 支持 .md / .txt，UTF-8。
/// 条目界定：一个**非空行块**（以空行分隔）；.md 的条目标题行作标题、随后的非空行为正文。
/// 解析结果为有序数组，供事务 / 学习子页顺序取用 + 循环回开头。
library;

/// 清单条目。
class ChecklistEntry {
  final String title;
  final String body;
  const ChecklistEntry({required this.title, this.body = ''});
}

/// 把文件文本解析为有序清单条目列表。
List<ChecklistEntry> parseChecklistFile(String text) {
  final blocks = text.split(RegExp(r'\n\s*\n'));
  final out = <ChecklistEntry>[];
  for (final b in blocks) {
    final lines = b
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (lines.isEmpty) continue;
    if (lines.length == 1) {
      out.add(ChecklistEntry(title: lines[0]));
    } else {
      out.add(ChecklistEntry(
        title: lines.first,
        body: lines.skip(1).join('\n'),
      ));
    }
  }
  return out;
}
