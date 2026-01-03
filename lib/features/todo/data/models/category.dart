import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    required String id,
    required String name,
    required int colorValue,
  }) = _Category;

  Color get color => Color(colorValue);

  static const List<Category> defaults = [
    Category(id: 'work', name: 'Work', colorValue: 0xFF2196F3),
    Category(id: 'personal', name: 'Personal', colorValue: 0xFF4CAF50),
    Category(id: 'shopping', name: 'Shopping', colorValue: 0xFFFF9800),
  ];

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
