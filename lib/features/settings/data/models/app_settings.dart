import 'package:freezed_annotation/freezed_annotation.dart';

import 'sort_order.dart';
import 'theme_mode_option.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default('ja') String locale,
    @Default(ThemeModeOption.system) ThemeModeOption themeMode,
    @Default(SortOrder.createdAt) SortOrder sortOrder,
    @Default(true) bool showCompleted,
    String? defaultCategoryId,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
