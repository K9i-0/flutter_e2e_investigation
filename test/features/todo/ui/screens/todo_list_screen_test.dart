import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_e2e_investigation/features/todo/data/models/category.dart';
import 'package:flutter_e2e_investigation/features/todo/data/models/todo.dart';
import 'package:flutter_e2e_investigation/features/todo/providers/category_provider.dart';
import 'package:flutter_e2e_investigation/features/todo/providers/todo_provider.dart';
import 'package:flutter_e2e_investigation/features/todo/ui/screens/todo_list_screen.dart';
import 'package:flutter_e2e_investigation/features/todo/ui/widgets/category_chip.dart';
import 'package:flutter_e2e_investigation/features/settings/providers/settings_provider.dart';
import 'package:flutter_e2e_investigation/features/settings/data/models/app_settings.dart';
import 'package:flutter_e2e_investigation/features/settings/data/models/completion_filter.dart';

void main() {
  group('TodoListScreen category filtering', () {
    late List<Todo> testTodos;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testTodos = [
        Todo(
          id: 'work-1',
          title: 'Work Task 1',
          categoryId: 'work',
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        Todo(
          id: 'work-2',
          title: 'Work Task 2',
          categoryId: 'work',
          isCompleted: true, // completed
          createdAt: now.subtract(const Duration(hours: 1)),
          updatedAt: now,
        ),
        Todo(
          id: 'personal-1',
          title: 'Personal Task 1',
          categoryId: 'personal',
          isCompleted: false,
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now,
        ),
        Todo(
          id: 'shopping-1',
          title: 'Shopping Task 1',
          categoryId: 'shopping',
          isCompleted: true, // completed
          createdAt: now.subtract(const Duration(hours: 3)),
          updatedAt: now,
        ),
      ];
    });

    Widget buildTestWidget({
      required List<Override> overrides,
    }) {
      return ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          home: TodoListScreen(),
        ),
      );
    }

    /// Find category chip by category id using the widget type
    Finder findCategoryChip(String categoryId) {
      if (categoryId == 'all') {
        return find.byType(AllCategoryChip);
      }
      return find.byWidgetPredicate(
        (widget) =>
            widget is CategoryChip && widget.category.id == categoryId,
      );
    }

    testWidgets(
      'switching categories preserves correct checkbox states per frame',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            overrides: [
              todosProvider.overrideWith(() => _TestTodosNotifier(testTodos)),
              categoriesProvider.overrideWith(
                () => _TestCategoriesNotifier(Category.defaults),
              ),
              settingsProvider.overrideWith(
                () => _TestSettingsNotifier(
                  const AppSettings(completionFilter: CompletionFilter.all),
                ),
              ),
            ],
          ),
        );

        // Wait for initial render
        await tester.pumpAndSettle();

        // Verify initial state - should show all 4 todos
        expect(find.text('Work Task 1'), findsOneWidget);
        expect(find.text('Work Task 2'), findsOneWidget);
        expect(find.text('Personal Task 1'), findsOneWidget);
        expect(find.text('Shopping Task 1'), findsOneWidget);

        // Count completed checkboxes (should be 2: work-2 and shopping-1)
        final initialCheckIcons = find.byIcon(Icons.check_rounded);
        expect(initialCheckIcons, findsNWidgets(2),
            reason: 'Should have 2 completed todos initially');

        // Tap on "Work" category chip
        await tester.tap(findCategoryChip('work'));

        // Capture checkbox states at each frame during transition
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 16)); // ~60fps

          // Find all todo tiles and verify their checkbox states
          final workTask1 = find.text('Work Task 1');
          final workTask2 = find.text('Work Task 2');
          final personalTask1 = find.text('Personal Task 1');
          final shoppingTask1 = find.text('Shopping Task 1');

          // After filtering, only Work tasks should be visible
          if (i > 5) {
            // After animation settles
            expect(workTask1, findsOneWidget,
                reason: 'Work Task 1 should be visible');
            expect(workTask2, findsOneWidget,
                reason: 'Work Task 2 should be visible');
            expect(personalTask1, findsNothing,
                reason: 'Personal Task 1 should NOT be visible');
            expect(shoppingTask1, findsNothing,
                reason: 'Shopping Task 1 should NOT be visible');
          }
        }

        await tester.pumpAndSettle();

        // Final verification: Only Work tasks visible
        expect(find.text('Work Task 1'), findsOneWidget);
        expect(find.text('Work Task 2'), findsOneWidget);
        expect(find.text('Personal Task 1'), findsNothing);
        expect(find.text('Shopping Task 1'), findsNothing);

        // Switch to Personal category
        await tester.tap(findCategoryChip('personal'));

        // Verify intermediate frames don't show wrong checkbox states
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 16));

          // The key test: verify no "ghost" checkboxes appear
          // Work Task 2 was completed, Personal Task 1 is not
          // If keys are wrong, Personal Task 1 might show as completed briefly
        }

        await tester.pumpAndSettle();

        // Only Personal task should be visible and NOT completed
        expect(find.text('Personal Task 1'), findsOneWidget);
        expect(find.text('Work Task 1'), findsNothing);
        expect(find.text('Work Task 2'), findsNothing);
        expect(find.text('Shopping Task 1'), findsNothing);

        // Switch back to All
        await tester.tap(findCategoryChip('all'));
        await tester.pumpAndSettle();

        // All todos should be visible again
        expect(find.text('Work Task 1'), findsOneWidget);
        expect(find.text('Work Task 2'), findsOneWidget);
        expect(find.text('Personal Task 1'), findsOneWidget);
        expect(find.text('Shopping Task 1'), findsOneWidget);
      },
    );

    testWidgets(
      'checkbox state matches todo.isCompleted after category switch',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            overrides: [
              todosProvider.overrideWith(() => _TestTodosNotifier(testTodos)),
              categoriesProvider.overrideWith(
                () => _TestCategoriesNotifier(Category.defaults),
              ),
              settingsProvider.overrideWith(
                () => _TestSettingsNotifier(
                  const AppSettings(completionFilter: CompletionFilter.all),
                ),
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        // Filter to Shopping (has 1 completed task)
        await tester.tap(findCategoryChip('shopping'));
        await tester.pumpAndSettle();

        // Shopping Task 1 should show completed checkbox
        expect(find.text('Shopping Task 1'), findsOneWidget);
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);

        // Switch to Personal (has 1 uncompleted task)
        await tester.tap(findCategoryChip('personal'));

        // Pump frame by frame and verify no check icon appears
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 16));

          // Personal Task 1 is NOT completed, so check icon should not appear
          // This is the key assertion that catches the bug
          final checkIcons = find.byIcon(Icons.check_rounded);
          expect(
            checkIcons,
            findsNothing,
            reason:
                'Frame $i: Personal Task 1 is not completed, but check icon appeared',
          );
        }

        await tester.pumpAndSettle();

        // Final state: Personal visible, no check icon
        expect(find.text('Personal Task 1'), findsOneWidget);
        expect(find.byIcon(Icons.check_rounded), findsNothing);
      },
    );
  });
}

/// Test notifier that provides static todo list
class _TestTodosNotifier extends AsyncNotifier<List<Todo>>
    implements TodosNotifier {
  final List<Todo> _todos;

  _TestTodosNotifier(this._todos);

  @override
  Future<List<Todo>> build() async => _todos;

  @override
  Future<void> addTodo({
    required String title,
    String? description,
    String? categoryId,
    DateTime? dueDate,
    String? imagePath,
  }) async {}

  @override
  Future<void> updateTodo(
    Todo todo, {
    String? newImagePath,
    bool removeImage = false,
  }) async {}

  @override
  Future<void> toggleCompleted(String todoId) async {}

  @override
  Future<void> deleteTodo(String todoId) async {}

  @override
  Future<void> generateDebugTodos(int count) async {}

  @override
  Future<void> clearAllTodos() async {}
}

/// Test notifier for categories
class _TestCategoriesNotifier extends AsyncNotifier<List<Category>>
    implements CategoriesNotifier {
  final List<Category> _categories;

  _TestCategoriesNotifier(this._categories);

  @override
  Future<List<Category>> build() async => _categories;
}

/// Test notifier for settings
class _TestSettingsNotifier extends AsyncNotifier<AppSettings>
    implements SettingsNotifier {
  final AppSettings _settings;

  _TestSettingsNotifier(this._settings);

  @override
  Future<AppSettings> build() async => _settings;

  @override
  Future<void> updateThemeMode(value) async {}

  @override
  Future<void> updateLocale(String locale) async {}

  @override
  Future<void> updateSortOrder(value) async {}

  @override
  Future<void> updateCompletionFilter(CompletionFilter filter) async {}

  @override
  Future<void> updateDefaultCategoryId(String? categoryId) async {}

  @override
  Future<void> resetSettings() async {}
}
