import 'package:flutter_test/flutter_test.dart';
import 'package:advance_trainer/engine/language_detector.dart';
import 'package:advance_trainer/engine/tts_service.dart';

void main() {
  group('splitByLanguage 行内多语言混排', () {
    test('纯中文 → 单段 zh', () {
      final segs = splitByLanguage('你好，世界。');
      expect(segs.length, 1);
      expect(segs.first.lang, TtsLang.zh);
    });

    test('纯日文（假名+汉字）→ 单段 ja', () {
      final segs = splitByLanguage('おはようございます。');
      expect(segs.length, 1);
      expect(segs.first.lang, TtsLang.ja);
    });

    test('中英混排一行 → 切成 zh/en 交替', () {
      final segs = splitByLanguage('回答：I am fine, thank you. 我很好。');
      expect(segs.length, greaterThan(1));
      expect(segs.any((s) => s.lang == TtsLang.zh), isTrue);
      expect(segs.any((s) => s.lang == TtsLang.en), isTrue);
    });

    test('中日混排一行 → 日文段判 ja，中文段判 zh', () {
      // 典型日语清单行：词汇：おはよう 来自 早い（早）
      final segs = splitByLanguage('词汇：おはよう 来自 早い（早）');
      expect(segs.any((s) => s.lang == TtsLang.ja), isTrue);
      expect(segs.any((s) => s.lang == TtsLang.zh), isTrue);
    });

    test('日文核心句（含汉字假名）整行 → 判 ja', () {
      final segs = splitByLanguage('核心句：おはようございます。');
      expect(segs.any((s) => s.lang == TtsLang.ja), isTrue);
    });

    test('俄语西里尔 → 判 ru', () {
      final segs = splitByLanguage('Привет, как дела?');
      expect(segs.any((s) => s.lang == TtsLang.ru), isTrue);
    });

    test('韩语谚文 → 判 ko', () {
      final segs = splitByLanguage('안녕하세요');
      expect(segs.any((s) => s.lang == TtsLang.ko), isTrue);
    });

    test('相邻同语言片段被合并', () {
      // 连续中文（含标点）不应切成多段
      final segs = splitByLanguage('这是中文，也是中文。');
      expect(segs.length, 1);
      expect(segs.first.lang, TtsLang.zh);
    });

    test('空文本 → 空列表', () {
      expect(splitByLanguage(''), isEmpty);
      expect(splitByLanguage('   \n '), isEmpty);
    });
  });

  group('TtsService.unitsFor', () {
    test('标题 + 正文逐行切分', () {
      final units = TtsService.unitsFor('用英语见面打招呼', '核心句：Hello!\n意思：你好。');
      expect(units.length, greaterThanOrEqualTo(3));
      expect(units.any((u) => u.text.contains('用英语见面打招呼')), isTrue);
      expect(units.any((u) => u.lang == TtsLang.en), isTrue);
      expect(units.any((u) => u.lang == TtsLang.zh), isTrue);
    });

    test('空标题空正文 → 空', () {
      expect(TtsService.unitsFor('', ''), isEmpty);
    });
  });
}
