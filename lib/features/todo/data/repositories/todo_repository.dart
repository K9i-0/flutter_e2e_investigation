import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/todo.dart';

class TodoRepository {
  static const String _todosKey = 'todos';

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString(_todosKey);
    if (todosJson == null) return [];

    final List<dynamic> decoded = json.decode(todosJson);
    return decoded.map((e) => Todo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = json.encode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_todosKey, todosJson);
  }

  /// Copy image to app directory and return the permanent path
  Future<String> saveImage(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/todo_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${const Uuid().v4()}${p.extension(sourcePath)}';
    final destPath = '${imagesDir.path}/$fileName';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  /// Delete image file
  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
