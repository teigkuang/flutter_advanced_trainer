import 'package:flutter/material.dart';

import 'data/training_repository.dart';
import 'l10n/app_localizations.dart';
import 'ui/app_scope.dart';
import 'ui/home_page.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdvanceTrainerApp());
}

class AdvanceTrainerApp extends StatelessWidget {
  const AdvanceTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      repository: SqliteTrainingRepository(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('zh'), Locale('en')],
        // 中文为默认语言；仅当系统明确为英文时切英文，其余一律回退中文。
        localeResolutionCallback: (deviceLocale, supported) {
          if (deviceLocale != null && deviceLocale.languageCode == 'en') {
            return const Locale('en');
          }
          return const Locale('zh');
        },
        theme: buildTheme(),
        home: const HomePage(),
      ),
    );
  }
}
