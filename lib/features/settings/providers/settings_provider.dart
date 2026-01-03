import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
import '../data/models/completion_filter.dart';
import '../data/models/sort_order.dart';
import '../data/models/theme_mode_option.dart';
import '../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.loadSettings();
  }

  Future<void> updateLocale(String locale) async {
    final current = state.value ?? const AppSettings();
    final updated = current.copyWith(locale: locale);
    await _saveAndUpdate(updated);
  }

  Future<void> updateThemeMode(ThemeModeOption themeMode) async {
    final current = state.value ?? const AppSettings();
    final updated = current.copyWith(themeMode: themeMode);
    await _saveAndUpdate(updated);
  }

  Future<void> updateSortOrder(SortOrder sortOrder) async {
    final current = state.value ?? const AppSettings();
    final updated = current.copyWith(sortOrder: sortOrder);
    await _saveAndUpdate(updated);
  }

  Future<void> updateCompletionFilter(CompletionFilter filter) async {
    final current = state.value ?? const AppSettings();
    final updated = current.copyWith(completionFilter: filter);
    await _saveAndUpdate(updated);
  }

  Future<void> updateDefaultCategoryId(String? categoryId) async {
    final current = state.value ?? const AppSettings();
    final updated = current.copyWith(defaultCategoryId: categoryId);
    await _saveAndUpdate(updated);
  }

  Future<void> resetSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.clearSettings();
    state = const AsyncData(AppSettings());
  }

  Future<void> _saveAndUpdate(AppSettings settings) async {
    final repository = ref.read(settingsRepositoryProvider);
    state = AsyncData(settings);
    await repository.saveSettings(settings);
  }
}

// Derived providers for convenient access
final localeProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.locale ?? 'ja';
});

final themeModeProvider = Provider<ThemeModeOption>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.themeMode ??
      ThemeModeOption.system;
});

final sortOrderProvider = Provider<SortOrder>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.sortOrder ??
      SortOrder.createdAt;
});

final completionFilterProvider = Provider<CompletionFilter>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.completionFilter ??
      CompletionFilter.all;
});

final defaultCategoryIdProvider = Provider<String?>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.defaultCategoryId;
});
