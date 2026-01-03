import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/category.dart';
import '../data/models/todo.dart';
import '../data/repositories/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

final todosProvider =
    AsyncNotifierProvider<TodosNotifier, List<Todo>>(TodosNotifier.new);

class TodosNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    final repository = ref.watch(todoRepositoryProvider);
    return repository.loadTodos();
  }

  Future<void> addTodo({
    required String title,
    String? description,
    String? categoryId,
    DateTime? dueDate,
    String? imagePath,
  }) async {
    final repository = ref.read(todoRepositoryProvider);
    final now = DateTime.now();

    // Save image to permanent location if provided
    String? savedImagePath;
    if (imagePath != null) {
      savedImagePath = await repository.saveImage(imagePath);
    }

    final todo = Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      categoryId: categoryId,
      dueDate: dueDate,
      imagePath: savedImagePath,
      createdAt: now,
      updatedAt: now,
    );

    final currentTodos = state.value ?? [];
    final newTodos = [...currentTodos, todo];

    state = AsyncData(newTodos);
    await repository.saveTodos(newTodos);
  }

  Future<void> updateTodo(
    Todo todo, {
    String? newImagePath,
    bool removeImage = false,
  }) async {
    final repository = ref.read(todoRepositoryProvider);
    final currentTodos = state.value ?? [];
    final oldTodo = currentTodos.firstWhere((t) => t.id == todo.id);

    String? finalImagePath = todo.imagePath;

    // Handle image changes
    if (removeImage) {
      // Delete old image file if exists
      if (oldTodo.imagePath != null) {
        await repository.deleteImage(oldTodo.imagePath!);
      }
      finalImagePath = null;
    } else if (newImagePath != null) {
      // Delete old image file if exists
      if (oldTodo.imagePath != null) {
        await repository.deleteImage(oldTodo.imagePath!);
      }
      // Save new image
      finalImagePath = await repository.saveImage(newImagePath);
    }

    final updatedTodo = todo.copyWith(
      updatedAt: DateTime.now(),
      imagePath: finalImagePath,
    );

    final newTodos = currentTodos.map((t) {
      return t.id == updatedTodo.id ? updatedTodo : t;
    }).toList();

    state = AsyncData(newTodos);
    await repository.saveTodos(newTodos);
  }

  Future<void> toggleCompleted(String todoId) async {
    final currentTodos = state.value ?? [];
    final todo = currentTodos.firstWhere((t) => t.id == todoId);
    await updateTodo(todo.copyWith(isCompleted: !todo.isCompleted));
  }

  Future<void> deleteTodo(String todoId) async {
    final repository = ref.read(todoRepositoryProvider);
    final currentTodos = state.value ?? [];

    // Find the todo and delete its image if exists
    final todoToDelete = currentTodos.firstWhere((t) => t.id == todoId);
    if (todoToDelete.imagePath != null) {
      await repository.deleteImage(todoToDelete.imagePath!);
    }

    final newTodos = currentTodos.where((t) => t.id != todoId).toList();

    state = AsyncData(newTodos);
    await repository.saveTodos(newTodos);
  }

  /// Debug: Generate multiple dummy TODOs for testing
  Future<void> generateDebugTodos(int count) async {
    final repository = ref.read(todoRepositoryProvider);
    final random = Random();
    final now = DateTime.now();
    final categories = Category.defaults;

    final debugTodos = List.generate(count, (index) {
      final createdAt = now.subtract(Duration(hours: index));
      final categoryId = categories[random.nextInt(categories.length)].id;
      final hasDescription = random.nextBool();
      final hasDueDate = random.nextBool();
      final isCompleted = random.nextDouble() < 0.2; // 20% completed

      return Todo(
        id: const Uuid().v4(),
        title: 'Debug Task ${index + 1}',
        description: hasDescription ? 'This is a debug task #${index + 1}' : null,
        categoryId: categoryId,
        dueDate: hasDueDate
            ? now.add(Duration(days: random.nextInt(14) - 3))
            : null,
        isCompleted: isCompleted,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
    });

    final currentTodos = state.value ?? [];
    final newTodos = [...currentTodos, ...debugTodos];

    state = AsyncData(newTodos);
    await repository.saveTodos(newTodos);
  }

  /// Debug: Clear all TODOs
  Future<void> clearAllTodos() async {
    final repository = ref.read(todoRepositoryProvider);
    final currentTodos = state.value ?? [];

    // Delete all images
    for (final todo in currentTodos) {
      if (todo.imagePath != null) {
        await repository.deleteImage(todo.imagePath!);
      }
    }

    state = const AsyncData([]);
    await repository.saveTodos([]);
  }
}
