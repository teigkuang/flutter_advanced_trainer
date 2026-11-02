import 'package:flutter/material.dart';

import 'data/training_repository.dart';
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
        title: '进阶训练器',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomePage(),
      ),
    );
  }
}
