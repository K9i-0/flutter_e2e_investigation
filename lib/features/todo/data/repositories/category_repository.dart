import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';

class CategoryRepository {
  static const String _categoriesKey = 'categories';

  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_categoriesKey);
    if (categoriesJson == null) {
      // Return default categories on first load
      return Category.defaults;
    }

    final List<dynamic> decoded = json.decode(categoriesJson);
    return decoded
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson =
        json.encode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_categoriesKey, categoriesJson);
  }
}
