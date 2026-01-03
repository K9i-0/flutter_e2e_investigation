import 'sort_order.dart';
import 'theme_mode_option.dart';

class AppSettings {
  const AppSettings({
    this.locale = 'ja',
    this.themeMode = ThemeModeOption.system,
    this.sortOrder = SortOrder.createdAt,
    this.showCompleted = true,
    this.defaultCategoryId,
  });

  final String locale;
  final ThemeModeOption themeMode;
  final SortOrder sortOrder;
  final bool showCompleted;
  final String? defaultCategoryId;

  AppSettings copyWith({
    String? locale,
    ThemeModeOption? themeMode,
    SortOrder? sortOrder,
    bool? showCompleted,
    String? defaultCategoryId,
    bool clearDefaultCategoryId = false,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      sortOrder: sortOrder ?? this.sortOrder,
      showCompleted: showCompleted ?? this.showCompleted,
      defaultCategoryId: clearDefaultCategoryId
          ? null
          : (defaultCategoryId ?? this.defaultCategoryId),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'themeMode': themeMode.toJson(),
      'sortOrder': sortOrder.toJson(),
      'showCompleted': showCompleted,
      'defaultCategoryId': defaultCategoryId,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      locale: json['locale'] as String? ?? 'ja',
      themeMode: json['themeMode'] != null
          ? ThemeModeOption.fromJson(json['themeMode'] as String)
          : ThemeModeOption.system,
      sortOrder: json['sortOrder'] != null
          ? SortOrder.fromJson(json['sortOrder'] as String)
          : SortOrder.createdAt,
      showCompleted: json['showCompleted'] as bool? ?? true,
      defaultCategoryId: json['defaultCategoryId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.locale == locale &&
        other.themeMode == themeMode &&
        other.sortOrder == sortOrder &&
        other.showCompleted == showCompleted &&
        other.defaultCategoryId == defaultCategoryId;
  }

  @override
  int get hashCode {
    return Object.hash(
      locale,
      themeMode,
      sortOrder,
      showCompleted,
      defaultCategoryId,
    );
  }
}
