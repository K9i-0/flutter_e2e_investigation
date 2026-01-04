import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/dev_tools/talker.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../todo/providers/category_provider.dart';
import '../../../todo/providers/todo_provider.dart';
import '../../data/models/completion_filter.dart';
import '../../data/models/sort_order.dart';
import '../../data/models/theme_mode_option.dart';
import '../../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Semantics(
          identifier: 'settings-back-button',
          label: 'Go back',
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          l10n.settings,
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: settings.when(
        data: (s) => ListView(
          children: [
            // Appearance Section
            SettingsSection(
              title: l10n.appearance,
              children: [
                Semantics(
                  identifier: 'language-selector',
                  label: l10n.language,
                  child: SettingsValueTile<String>(
                    title: l10n.language,
                    value: s.locale,
                    options: [
                      SettingsOption(value: 'en', label: l10n.languageEnglish),
                      SettingsOption(value: 'ja', label: l10n.languageJapanese),
                    ],
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateLocale(value);
                    },
                    isFirst: true,
                  ),
                ),
                Semantics(
                  identifier: 'theme-selector',
                  label: l10n.theme,
                  child: SettingsValueTile<ThemeModeOption>(
                    title: l10n.theme,
                    value: s.themeMode,
                    options: [
                      SettingsOption(
                          value: ThemeModeOption.light, label: l10n.themeLight),
                      SettingsOption(
                          value: ThemeModeOption.dark, label: l10n.themeDark),
                      SettingsOption(
                          value: ThemeModeOption.system,
                          label: l10n.themeSystem),
                    ],
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateThemeMode(value);
                    },
                    isLast: true,
                  ),
                ),
              ],
            ),

            // Defaults Section
            SettingsSection(
              title: l10n.defaults,
              children: [
                Semantics(
                  identifier: 'sort-selector',
                  label: l10n.sortOrder,
                  child: SettingsValueTile<SortOrder>(
                    title: l10n.sortOrder,
                    value: s.sortOrder,
                    options: [
                      SettingsOption(
                          value: SortOrder.createdAt,
                          label: l10n.sortByCreatedAt),
                      SettingsOption(
                          value: SortOrder.dueDate, label: l10n.sortByDueDate),
                      SettingsOption(
                          value: SortOrder.name, label: l10n.sortByName),
                    ],
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateSortOrder(value);
                    },
                    isFirst: true,
                  ),
                ),
                Semantics(
                  identifier: 'completion-filter-selector',
                  label: l10n.showCompletedTasks,
                  child: SettingsValueTile<CompletionFilter>(
                    title: l10n.showCompletedTasks,
                    value: s.completionFilter,
                    options: [
                      SettingsOption(
                          value: CompletionFilter.all, label: 'All'),
                      SettingsOption(
                          value: CompletionFilter.incomplete,
                          label: 'Incomplete only'),
                      SettingsOption(
                          value: CompletionFilter.completed,
                          label: 'Completed only'),
                    ],
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateCompletionFilter(value);
                    },
                  ),
                ),
                Semantics(
                  identifier: 'default-category-selector',
                  label: l10n.defaultCategory,
                  child: categories.when(
                    data: (cats) => SettingsValueTile<String?>(
                      title: l10n.defaultCategory,
                      value: s.defaultCategoryId,
                      options: [
                        SettingsOption(value: null, label: l10n.categoryNone),
                        ...cats.map((c) =>
                            SettingsOption(value: c.id, label: c.name)),
                      ],
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateDefaultCategoryId(value);
                      },
                      isLast: true,
                    ),
                    loading: () => SettingsTile(
                      title: l10n.defaultCategory,
                      isLast: true,
                    ),
                    error: (_, _) => SettingsTile(
                      title: l10n.defaultCategory,
                      isLast: true,
                    ),
                  ),
                ),
              ],
            ),

            // Data Management Section
            SettingsSection(
              title: l10n.dataManagement,
              children: [
                Semantics(
                  identifier: 'delete-completed-button',
                  label: l10n.deleteCompletedTasks,
                  child: SettingsTile(
                    title: l10n.deleteCompletedTasks,
                    subtitle: l10n.deleteCompletedTasksDescription,
                    isFirst: true,
                    isDestructive: true,
                    onTap: () => _showDeleteCompletedDialog(context, ref, l10n),
                  ),
                ),
                Semantics(
                  identifier: 'clear-all-button',
                  label: l10n.clearAllData,
                  child: SettingsTile(
                    title: l10n.clearAllData,
                    subtitle: l10n.clearAllDataDescription,
                    isLast: true,
                    isDestructive: true,
                    onTap: () => _showClearAllDialog(context, ref, l10n),
                  ),
                ),
              ],
            ),

            // About Section
            SettingsSection(
              title: l10n.about,
              children: [
                SettingsTile(
                  title: l10n.version,
                  trailing: Text(
                    '1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  isFirst: true,
                ),
                Semantics(
                  identifier: 'licenses-button',
                  label: l10n.licenses,
                  child: SettingsTile(
                    title: l10n.licenses,
                    subtitle: l10n.licensesDescription,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.outline,
                    ),
                    isLast: true,
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'TODO',
                        applicationVersion: '1.0.0',
                      );
                    },
                  ),
                ),
              ],
            ),

            // Debug Section (only in debug mode)
            if (kDebugMode)
              SettingsSection(
                title: 'Debug',
                children: [
                  Semantics(
                    identifier: 'debug-view-logs',
                    label: 'View logs',
                    child: SettingsTile(
                      title: 'View Logs',
                      subtitle: 'Open Talker debug console',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.outline,
                      ),
                      isFirst: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TalkerScreen(talker: talker),
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    identifier: 'debug-generate-todos',
                    label: 'Generate 30 debug TODOs',
                    child: SettingsTile(
                      title: 'Generate 30 TODOs',
                      subtitle: 'Create dummy tasks for testing',
                      onTap: () => _generateDebugTodos(context, ref),
                    ),
                  ),
                  Semantics(
                    identifier: 'debug-clear-todos',
                    label: 'Clear all TODOs',
                    child: SettingsTile(
                      title: 'Clear All TODOs',
                      subtitle: 'Delete all tasks without confirmation',
                      isLast: true,
                      isDestructive: true,
                      onTap: () => _clearAllTodos(context, ref),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _showDeleteCompletedDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCompletedTasks),
        content: Text(l10n.deleteCompletedConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final todos = ref.read(todosProvider).valueOrNull ?? [];
      final completedIds =
          todos.where((t) => t.isCompleted).map((t) => t.id).toList();

      for (final id in completedIds) {
        await ref.read(todosProvider.notifier).deleteTodo(id);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tasksDeleted(completedIds.length))),
        );
      }
    }
  }

  Future<void> _showClearAllDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.clearAllDataConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Delete all todos
      final todos = ref.read(todosProvider).valueOrNull ?? [];
      for (final todo in todos) {
        await ref.read(todosProvider.notifier).deleteTodo(todo.id);
      }

      // Reset settings
      await ref.read(settingsProvider.notifier).resetSettings();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dataCleared)),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _generateDebugTodos(BuildContext context, WidgetRef ref) async {
    await ref.read(todosProvider.notifier).generateDebugTodos(30);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generated 30 debug TODOs')),
      );
    }
  }

  Future<void> _clearAllTodos(BuildContext context, WidgetRef ref) async {
    await ref.read(todosProvider.notifier).clearAllTodos();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All TODOs cleared')),
      );
    }
  }
}
