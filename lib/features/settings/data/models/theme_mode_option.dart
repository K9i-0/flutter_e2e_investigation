import 'package:flutter/material.dart';

enum ThemeModeOption {
  light,
  dark,
  system;

  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  String toJson() => name;

  static ThemeModeOption fromJson(String json) {
    return ThemeModeOption.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ThemeModeOption.system,
    );
  }
}
