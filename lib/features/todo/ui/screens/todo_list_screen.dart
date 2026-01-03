import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/providers/settings_provider.dart';
import '../../../settings/ui/screens/settings_screen.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/filtered_todos_provider.dart';
import '../../providers/todo_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar.dart';
import '../widgets/todo_tile.dart';
import 'todo_edit_screen.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToEdit(BuildContext context, {dynamic todo}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => TodoEditScreen(todo: todo),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTodos = ref.watch(filteredTodosProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final showCompleted = ref.watch(showCompletedProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'TODO',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    identifier: 'toggle-completed',
                    label: showCompleted ? 'Hide completed' : 'Show completed',
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          showCompleted
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          key: ValueKey(showCompleted),
                          color: showCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      ),
                      onPressed: () {
                        ref
                            .read(settingsProvider.notifier)
                            .updateShowCompleted(!showCompleted);
                      },
                      tooltip: showCompleted ? 'Hide completed' : 'Show completed',
                    ),
                  ),
                  Semantics(
                    identifier: 'settings-button',
                    label: 'Settings',
                    child: IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: theme.colorScheme.outline,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      tooltip: 'Settings',
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            TodoSearchBar(
              controller: _searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),

            // Category filter chips
            categories.when(
              data: (cats) => SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    AllCategoryChip(
                      isSelected: selectedCategoryId == null,
                      onTap: () {
                        ref.read(selectedCategoryIdProvider.notifier).state =
                            null;
                      },
                    ),
                    const SizedBox(width: 8),
                    ...cats.map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            category: cat,
                            isSelected: selectedCategoryId == cat.id,
                            onTap: () {
                              ref.read(selectedCategoryIdProvider.notifier).state =
                                  selectedCategoryId == cat.id ? null : cat.id;
                            },
                          ),
                        )),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 48),
              error: (_, __) => const SizedBox(height: 48),
            ),

            const SizedBox(height: 16),

            // Todo list
            Expanded(
              child: filteredTodos.when(
                data: (todos) {
                  if (todos.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      final category = categories.valueOrNull?.firstWhere(
                        (c) => c.id == todo.categoryId,
                        orElse: () => Category.defaults.first,
                      );

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: TodoTile(
                          todo: todo,
                          category: todo.categoryId != null ? category : null,
                          onToggleCompleted: () {
                            ref.read(todosProvider.notifier).toggleCompleted(todo.id);
                          },
                          onTap: () => _navigateToEdit(context, todo: todo),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Semantics(
        identifier: 'todo-fab-add',
        label: 'Add new todo',
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToEdit(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Task'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All caught up!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks to show.\nTap the button below to create one.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
