/// UI 设计令牌 · 对齐《UI设计规范》
library;

import 'package:flutter/material.dart';

abstract class AppColors {
  static const ink = Color(0xFF1e1b18);
  static const paper = Color(0xFFf3f1ec);
  static const card = Colors.white;
  static const line = Color(0xFFe6e2d9);
  static const mut = Color(0xFF8a857c);
  static const acc = Color(0xFFe2540f);
  static const accSoft = Color(0xFFfdeee3);
  static const ok = Color(0xFF1f8f5a);
  static const okSoft = Color(0xFFe7f4ed);
  static const warn = Color(0xFFb7791f);
  static const dim = Color(0xFFd9d5cc);
  static const danger = Color(0xFFc0392b);
}

const _fontFamily = 'MicrosoftYaHei';

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.acc,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.paper,
    fontFamily: _fontFamily,
  );
  return base.copyWith(
    popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.ink,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.acc,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        disabledBackgroundColor: AppColors.dim,
        disabledForegroundColor: const Color(0xFFa6a199),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.line),
        foregroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.acc, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    ),
  );
}
