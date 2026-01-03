import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/todo.dart';
import 'filter_provider.dart';
import 'todo_provider.dart';

final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todosProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
  final showCompleted = ref.watch(showCompletedProvider);

  return todosAsync.whenData((todos) {
    return todos.where((todo) {
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
  });
});
