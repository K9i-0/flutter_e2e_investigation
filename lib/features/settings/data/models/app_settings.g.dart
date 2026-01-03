// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  locale: json['locale'] as String? ?? 'ja',
  themeMode:
      $enumDecodeNullable(_$ThemeModeOptionEnumMap, json['themeMode']) ??
      ThemeModeOption.system,
  sortOrder:
      $enumDecodeNullable(_$SortOrderEnumMap, json['sortOrder']) ??
      SortOrder.createdAt,
  showCompleted: json['showCompleted'] as bool? ?? true,
  defaultCategoryId: json['defaultCategoryId'] as String?,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'themeMode': _$ThemeModeOptionEnumMap[instance.themeMode]!,
      'sortOrder': _$SortOrderEnumMap[instance.sortOrder]!,
      'showCompleted': instance.showCompleted,
      'defaultCategoryId': instance.defaultCategoryId,
    };

const _$ThemeModeOptionEnumMap = {
  ThemeModeOption.light: 'light',
  ThemeModeOption.dark: 'dark',
  ThemeModeOption.system: 'system',
};

const _$SortOrderEnumMap = {
  SortOrder.createdAt: 'createdAt',
  SortOrder.dueDate: 'dueDate',
  SortOrder.name: 'name',
};
