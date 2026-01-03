import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/data/models/sort_order.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/models/todo.dart';
import 'filter_provider.dart';
import 'todo_provider.dart';

final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todosProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
  final showCompleted = ref.watch(showCompletedProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  return todosAsync.whenData((todos) {
    var filteredTodos = todos.where((todo) {
      // Filter by completion status
      if (!showCompleted && todo.isCompleted) {
        return false;
      }

      // Filter by category
      if (selectedCategoryId != null && todo.categoryId != selectedCategoryId) {
        return false;
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final titleMatch = todo.title.toLowerCase().contains(searchQuery);
        final descMatch =
            todo.description?.toLowerCase().contains(searchQuery) ?? false;
        if (!titleMatch && !descMatch) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort todos
    filteredTodos.sort((a, b) {
      switch (sortOrder) {
        case SortOrder.createdAt:
          return b.createdAt.compareTo(a.createdAt); // Newest first
        case SortOrder.dueDate:
          // Todos without due date go to the end
          if (a.dueDate == null && b.dueDate == null) {
            return b.createdAt.compareTo(a.createdAt);
          }
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!); // Earliest first
        case SortOrder.name:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return filteredTodos;
  });
});
