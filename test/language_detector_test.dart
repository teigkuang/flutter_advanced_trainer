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
      expect(segs.any((s) => s.lang == TtsLang.zh), isTrue);
      expect(segs.any((s) => s.lang == TtsLang.en), isTrue);
    });

    test('中日混排一行 → 日文段判 ja，中文段判 zh', () {
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
      final segs = splitByLanguage('这是中文，也是中文。');
      expect(segs.length, 1);
      expect(segs.first.lang, TtsLang.zh);
    });

    test('空文本 → 空列表', () {
      expect(splitByLanguage(''), isEmpty);
      expect(splitByLanguage('   \n '), isEmpty);
    });

    test('英文撇号/缩写不再被拆开（it\'s 不读成 it 引号 s）', () {
      final segs = splitByLanguage("It's been a while");
      // 整段应为英文，且撇号不产生独立片段。
      expect(segs.length, 1);
      expect(segs.first.lang, TtsLang.en);
      expect(segs.first.text, "It's been a while");
    });

    test('英文感叹号/问号不再单独成段', () {
      final segs = splitByLanguage('Hello! How are you?');
      expect(segs.any((s) => s.lang == TtsLang.en), isTrue);
      expect(segs.every((s) => s.lang == TtsLang.en), isTrue);
      expect(segs.map((s) => s.text).join(), 'Hello! How are you?');
    });

    test('括号作为强边界：早い（早）→ ja + zh 两段', () {
      final segs = splitByLanguage('早い（早）');
      // 「早い」含假名 → ja；「（早）」纯汉字 → zh。
      expect(segs.length, 2);
      expect(segs[0].lang, TtsLang.ja);
      expect(segs[1].lang, TtsLang.zh);
      expect(segs[1].text, '（早）');
    });

    test('汉字紧邻片假名 → 并入 ja（漢字カタカナ）', () {
      final segs = splitByLanguage('漢字カタカナ');
      expect(segs.length, 1);
      expect(segs.first.lang, TtsLang.ja);
    });

    test('括号内中文解释不并入日文', () {
      // 典型日语清单行：词汇：おはよう 来自 早い（早），ございます 是敬语
      final segs = splitByLanguage('词汇：おはよう 来自 早い（早），ございます 是敬语');
      // 应同时含 ja 段和 zh 段。
      expect(segs.any((s) => s.lang == TtsLang.ja), isTrue);
      expect(segs.any((s) => s.lang == TtsLang.zh), isTrue);
      // 括号段「（早）」应是 zh。
      final paren = segs.firstWhere((s) => s.text.contains('早）'),
          orElse: () => const LangSegment(lang: TtsLang.zh, text: ''));
      expect(paren.lang, TtsLang.zh);
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

    test('英文缩写保留为完整英文片段', () {
      final units = TtsService.unitsFor('', "It's been a while");
      expect(units.length, 1);
      expect(units.first.lang, TtsLang.en);
      expect(units.first.text, "It's been a while");
    });
  });

  group('全角中文标点在拉丁段中被剔除（不被英文 TTS 读出）', () {
    test('英文后跟全角句号 → 句号被剔除，英文段干净', () {
      final segs = splitByLanguage('I am fine. 我很好。');
      final enSeg = segs.firstWhere((s) => s.lang == TtsLang.en);
      expect(enSeg.text.contains('。'), isFalse);
      expect(enSeg.text.contains('.'), isTrue); // ASCII 句号保留
      final zhSeg = segs.firstWhere((s) => s.lang == TtsLang.zh);
      expect(zhSeg.text, contains('。')); // 中文段标点保留
    });

    test('英文词之间夹全角顿号/逗号 → 剔除并保留空格分隔', () {
      final segs = splitByLanguage('apple、banana，orange');
      // 全角顿号/逗号不应进入英文段
      expect(segs.every((s) => !s.text.contains('、') && !s.text.contains('，')),
          isTrue);
      // 合并后英文仍是完整词序列，且不被粘连
      final en = segs.map((s) => s.text).join(' ');
      expect(en, contains('apple'));
      expect(en, contains('banana'));
      expect(en, contains('orange'));
    });

    test('英文后全角感叹号/问号被剔除', () {
      final segs = splitByLanguage('Hello! 你好？');
      final enSeg = segs.firstWhere((s) => s.lang == TtsLang.en);
      expect(enSeg.text.trim(), 'Hello!'); // ASCII 感叹号保留
      final zhSeg = segs.firstWhere((s) => s.lang == TtsLang.zh);
      expect(zhSeg.text, contains('？'));
    });

    test('纯英文句末全角标点 → 英文段不含该标点', () {
      final segs = splitByLanguage("It's been a while。");
      expect(segs.length, 1);
      expect(segs.first.lang, TtsLang.en);
      expect(segs.first.text.contains('。'), isFalse);
    });
  });
}
