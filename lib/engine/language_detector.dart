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

/// 单字符脚本判定（简化版，覆盖常见语种）。
TtsLang _scriptOfChar(String ch) {
  final r = ch.codeUnitAt(0);
  // 假名：平假名 U+3040–U+309F，片假名 U+30A0–U+30FF
  if ((r >= 0x3040 && r <= 0x309F) || (r >= 0x30A0 && r <= 0x30FF)) return TtsLang.ja;
  // 谚文 U+AC00–U+D7A3
  if (r >= 0xAC00 && r <= 0xD7A3) return TtsLang.ko;
  // 西里尔 U+0400–U+04FF
  if (r >= 0x0400 && r <= 0x04FF) return TtsLang.ru;
  // 拉丁字母
  if ((r >= 0x0041 && r <= 0x005A) || (r >= 0x0061 && r <= 0x007A) ||
      (r >= 0x00C0 && r <= 0x00FF)) {
    return TtsLang.en;
  }
  // CJK 统一汉字 U+4E00–U+9FFF（含日文汉字），默认中文，稍后按上下文修正
  if (r >= 0x4E00 && r <= 0x9FFF) return TtsLang.zh;
  // 其他（数字、标点、空白、全角符号）→ 返回 null 表示并入相邻片段
  return TtsLang.zh; // 占位，调用方按需处理
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
List<LangSegment> splitByLanguage(String text) {
  if (text.isEmpty) return const [];
  final segments = <LangSegment>[];
  final buf = StringBuffer();
  TtsLang? cur;

  void flush() {
    if (buf.isEmpty) return;
    final raw = buf.toString();
    final lang = _classifySegment(raw, cur ?? TtsLang.zh);
    segments.add(LangSegment(lang: lang, text: raw));
    buf.clear();
  }

  for (final ch in text.split('')) {
    if (ch.trim().isEmpty) {
      // 空白作为片段边界：结束当前片段（合并逻辑由 _classifySegment 保证相邻同语言合并）。
      flush();
      cur = null;
      continue;
    }
    final lang = _scriptOfChar(ch);
    if (lang == TtsLang.en) {
      if (cur != TtsLang.en) {
        flush();
        cur = TtsLang.en;
      }
      buf.write(ch);
    } else if (lang == TtsLang.zh) {
      // 汉字：若当前是日文片段（前面已有假名），并入 ja；否则按 zh 起片段。
      if (cur != TtsLang.zh && cur != TtsLang.ja) {
        flush();
        cur = TtsLang.zh;
      }
      buf.write(ch);
    } else {
      if (cur != lang) {
        flush();
        cur = lang;
      }
      buf.write(ch);
    }
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
