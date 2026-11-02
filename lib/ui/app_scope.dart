/// 应用作用域：向整棵 widget 树暴露共享依赖（仓储）。
library;

import 'package:flutter/widgets.dart';

import '../data/training_repository.dart';

class AppScope extends InheritedWidget {
  final TrainingRepository repository;

  const AppScope({super.key, required this.repository, required super.child});

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      repository != oldWidget.repository;
}
