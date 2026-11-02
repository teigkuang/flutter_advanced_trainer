import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:advance_trainer/l10n/app_localizations.dart';

// 与 lib/main.dart 保持一致的语言解析策略：中文默认，仅系统明确英文时用英文。
MaterialApp _appWith(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('zh'), Locale('en')],
    localeResolutionCallback: (deviceLocale, supported) {
      if (deviceLocale != null && deviceLocale.languageCode == 'en') {
        return const Locale('en');
      }
      return const Locale('zh');
    },
    home: child,
  );
}

void main() {
  Future<String> titleFor(WidgetTester tester, List<Locale> device) async {
    tester.binding.platformDispatcher.localesTestValue = device;
    String? t;
    await tester.pumpWidget(_appWith(Builder(builder: (context) {      t = AppLocalizations.of(context)!.appTitle;
      return const SizedBox();
    })));
    return t!;
  }

  testWidgets('zh_CN 设备 → 中文', (tester) async {
    expect(await titleFor(tester, [const Locale('zh', 'CN')]), '进阶训练器');
  });

  testWidgets('zh-Hans-CN 设备 → 中文', (tester) async {
    expect(
        await titleFor(
            tester, [Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN')]),
        '进阶训练器');
  });

  testWidgets('en_US 设备 → 英文', (tester) async {
    expect(await titleFor(tester, [const Locale('en', 'US')]), 'Advance Trainer');
  });

  testWidgets('未知语言(如 fr) 设备 → 回退中文', (tester) async {
    expect(await titleFor(tester, [const Locale('fr', 'FR')]), '进阶训练器');
  });
}
