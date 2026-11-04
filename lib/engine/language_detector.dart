/// 多语言检测与行内片段切分
///
/// 输入是用户上传清单的一行文本（可能中/英/日/法/俄/西等多语言混排），
/// 输出是按「语言」连续切分、并合并相邻同语言后的片段序列，供 TTS 逐片段朗读。
///
/// 规则要点：
///   - 假名（平/片假名）→ 日语 ja
///   - 谚文 → 韩语 ko
///   - 西里尔 → 俄语 ru
///   - 拉丁字母 → 按小写词表尽量区分 en/fr/es/de，未知归 en（英语兜底）
///   - 汉字：含假名时倾向日文（ja），否则中文（zh）
///   - 数字/标点/空白并入相邻片段，不单独成段
library;

/// 支持的语言代码（locale 前缀），可扩展。
enum TtsLang {
  zh('zh'),
  en('en'),
  ja('ja'),
  ko('ko'),
  ru('ru'),
  fr('fr'),
  es('es'),
  de('de');

  const TtsLang(this.code);
  final String code;

  /// flutter_tts 使用的完整 locale 标签。
  String get locale => switch (this) {
        zh => 'zh-CN',
        en => 'en-US',
        ja => 'ja-JP',
        ko => 'ko-KR',
        ru => 'ru-RU',
        fr => 'fr-FR',
        es => 'es-ES',
        de => 'de-DE',
      };

  static TtsLang fromCode(String code) =>
      values.firstWhere((l) => l.code == code, orElse: () => en);
}

/// 一段连续同语言的文本。
class LangSegment {
  final TtsLang lang;
  final String text;
  const LangSegment({required this.lang, required this.text});

  @override
  String toString() => '[$lang] $text';
}

/// 单字符脚本判定。
///
/// 返回对应语言；对标点/数字/符号等**中性字符**返回 null，
/// 由切分逻辑把它们并入相邻语言片段（不单独成段，避免 `it's` 被拆、`!` 被读出）。
TtsLang? _scriptOfChar(String ch) {
  final r = ch.codeUnitAt(0);
  // 假名：平假名 U+3040–U+309F，片假名 U+30A0–U+30FF
  if ((r >= 0x3040 && r <= 0x309F) || (r >= 0x30A0 && r <= 0x30FF)) return TtsLang.ja;
  // 谚文 U+AC00–U+D7A3
  if (r >= 0xAC00 && r <= 0xD7A3) return TtsLang.ko;
  // 西里尔 U+0400–U+04FF
  if (r >= 0x0400 && r <= 0x04FF) return TtsLang.ru;
  // 拉丁字母（含重音字符）
  if ((r >= 0x0041 && r <= 0x005A) || (r >= 0x0061 && r <= 0x007A) ||
      (r >= 0x00C0 && r <= 0x00FF)) {
    return TtsLang.en;
  }
  // CJK 统一汉字 U+4E00–U+9FFF（含日文汉字）
  if (r >= 0x4E00 && r <= 0x9FFF) return TtsLang.zh;
  // 其他（数字、标点、空白、符号、日文长音符等）→ 中性，并入相邻片段
  return null;
}

/// 判断一个字符（rune）是否为「中性字符」（无语言归属：空白/标点/数字/符号）。
/// 用于过滤纯符号片段，避免产生无意义的朗读段。
bool _isNeutralRune(int r) {
  // 假名
  if ((r >= 0x3040 && r <= 0x309F) || (r >= 0x30A0 && r <= 0x30FF)) return false;
  // 谚文
  if (r >= 0xAC00 && r <= 0xD7A3) return false;
  // 西里尔
  if (r >= 0x0400 && r <= 0x04FF) return false;
  // 拉丁
  if ((r >= 0x0041 && r <= 0x005A) || (r >= 0x0061 && r <= 0x007A) ||
      (r >= 0x00C0 && r <= 0x00FF)) {
    return false;
  }
  // CJK 汉字
  if (r >= 0x4E00 && r <= 0x9FFF) return false;
  return true; // 其他均为中性
}

/// 判断 StringBuffer 末尾字符是否为 CJK 汉字（用于“汉字直接紧邻假名”判定）。
bool _bufEndsWithHan(StringBuffer buf) {
  if (buf.isEmpty) return false;
  final last = buf.toString().runes.last;
  return last >= 0x4E00 && last <= 0x9FFF;
}

/// 简化拉丁词表识别：命中常见词 → 对应语言。
TtsLang _latinWordLang(String word) {
  final w = word.toLowerCase();
  const fr = {
    'le', 'la', 'les', 'un', 'une', 'des', 'de', 'du', 'et', 'est', 'que',
    'vous', 'nous', 'je', 'tu', 'il', 'elle', 'ce', 'cette', 'pour', 'avec',
    'bonjour', 'merci', 'au', 'aux', 'dans', 'sur', 'à', 'a', 'pas', 'oui',
    'non', 'par', 'mais', 'si', 'très', 'tres', 'bien', 'être', 'etre',
  };
  const es = {
    'el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas', 'y', 'es', 'de',
    'que', 'para', 'por', 'con', 'en', 'hola', 'gracias', 'buenos', 'buenas',
    'días', 'dias', 'no', 'sí', 'si', 'pero', 'muy', 'estoy', 'tengo',
  };
  const de = {
    'der', 'die', 'das', 'ein', 'eine', 'und', 'ist', 'nicht', 'ich', 'du',
    'er', 'sie', 'es', 'wir', 'mit', 'zu', 'auf', 'für', 'fur', 'guten',
    'danke', 'ja', 'nein', 'aber', 'sehr', 'wie', 'bitte',
  };
  if (fr.contains(w)) return TtsLang.fr;
  if (es.contains(w)) return TtsLang.es;
  if (de.contains(w)) return TtsLang.de;
  return TtsLang.en;
}

/// 把一段可能混排的文本切成「连续同语言」片段（相邻同语言已合并）。
///
/// 规则：
///   - 标点/数字/符号（_scriptOfChar 返回 null）并入相邻语言片段，不单独成段。
///   - 括号（（）()）作为强语言边界：括号内内容独立判定语言。
///     如「早い（早）」→「早い」(ja) +「（早）」(zh)。
///   - 汉字紧邻假名（同一无分隔串）→ 并入 ja；纯汉字段 → zh。
///     如「漢字カタカナ」→ ja；「词汇」→ zh。
List<LangSegment> splitByLanguage(String text) {
  if (text.isEmpty) return const [];
  final segments = <LangSegment>[];
  final buf = StringBuffer();
  TtsLang? cur; // 当前片段语言；null 表示尚未有语言字符（可能只有前导中性字符）

  void flush() {
    if (buf.isEmpty) return;
    final raw = buf.toString();
    // 跳过无任何语言字符的片段（纯空白/纯符号），避免产生无意义的朗读段。
    if (raw.runes.every((r) => _isNeutralRune(r))) {
      buf.clear();
      cur = null;
      return;
    }
    final lang = _classifySegment(raw, cur ?? TtsLang.zh);
    segments.add(LangSegment(lang: lang, text: raw));
    buf.clear();
    cur = null;
  }

  for (final ch in text.split('')) {
    if (ch.trim().isEmpty) {
      // 空白作为「软边界」：保留空格并结束当前片段（相邻同语言由 merge 阶段合并）。
      if (buf.isNotEmpty) {
        buf.write(ch);
        flush();
      }
      continue;
    }
    if (ch == '（' || ch == '(') {
      // 左括号：强制结束当前片段（括号内内容独立判定语言），括号本身并入即将开始的片段。
      flush();
      buf.write(ch);
      continue;
    }
    final lang = _scriptOfChar(ch);
    if (lang == null) {
      // 中性字符（标点/数字/符号）：并入当前片段；若尚无语言片段则暂存。
      buf.write(ch);
      continue;
    }
    // 有明确语言字符。
    if (cur == null) {
      cur = lang;
      buf.write(ch);
      continue;
    }
    // 中日紧邻：仅当汉字**直接**紧邻假名（段末为汉字）才并入 ja，
    // 如「漢字カタカナ」→ ja；而「词汇：」「来自」（空格/冒号分隔）不并入。
    if (lang == TtsLang.ja && cur == TtsLang.zh && _bufEndsWithHan(buf)) {
      cur = TtsLang.ja;
      buf.write(ch);
      continue;
    }
    if (cur == lang) {
      buf.write(ch);
      continue;
    }
    // 语言切换：结束当前片段，起新片段。
    flush();
    cur = lang;
    buf.write(ch);
  }
  flush();

  // 合并相邻同语言片段（如「你好 世界」两个 zh 片段合并为一段）。
  final merged = <LangSegment>[];
  for (final seg in segments) {
    if (merged.isNotEmpty && merged.last.lang == seg.lang) {
      merged[merged.length - 1] = LangSegment(
        lang: seg.lang,
        text: merged.last.text + seg.text,
      );
    } else {
      merged.add(seg);
    }
  }

  // 拉丁词后置修正：把整段再扫一遍，按词命中细分 fr/es/de
  final refined = <LangSegment>[];
  for (final seg in merged) {
    if (seg.lang == TtsLang.en && seg.text.length <= 200) {
      final words = seg.text
          .split(RegExp(r'[^A-Za-zÀ-ÿ]+'))
          .where((w) => w.isNotEmpty)
          .toList();
      TtsLang best = TtsLang.en;
      final votes = <TtsLang, int>{};
      for (final w in words) {
        final l = _latinWordLang(w);
        votes[l] = (votes[l] ?? 0) + 1;
        if (votes[l]! > (votes[best] ?? 0)) best = l;
      }
      // 至少命中 1 个非英语词才改写
      if (votes[best] != null && best != TtsLang.en &&
          (votes[TtsLang.en] ?? 0) < votes[best]!) {
        refined.add(LangSegment(lang: best, text: seg.text));
      } else {
        refined.add(seg);
      }
    } else {
      refined.add(seg);
    }
  }
  return refined;
}

/// 对单个片段做最终语言判定。
///
/// 规则：片段内含假名 → 日文（如「おはよう」「早い（早）」）；
/// 否则含汉字 → 中文；其余保留切分时的初判（如纯拉丁的 en/ru/ko）。
/// 这解决了「词汇：おはよう 来自 早い」——「词汇/来自」判 zh、
/// 「おはよう」「早い」判 ja，而不像整行判定那样全部误判为日文。
TtsLang _classifySegment(String raw, TtsLang fallback) {
  final runes = raw.runes;
  bool hasKana = false;
  bool hasHan = false;
  for (final r in runes) {
    if ((r >= 0x3040 && r <= 0x309F) || (r >= 0x30A0 && r <= 0x30FF)) {
      hasKana = true;
    } else if (r >= 0x4E00 && r <= 0x9FFF) {
      hasHan = true;
    }
  }
  if (hasKana) return TtsLang.ja;
  if (hasHan) return TtsLang.zh;
  return fallback;
}
