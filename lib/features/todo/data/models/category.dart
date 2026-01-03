import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int colorValue;

  Color get color => Color(colorValue);

  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Default categories
  static const List<Category> defaults = [
    Category(id: 'work', name: 'Work', colorValue: 0xFF2196F3),
    Category(id: 'personal', name: 'Personal', colorValue: 0xFF4CAF50),
    Category(id: 'shopping', name: 'Shopping', colorValue: 0xFFFF9800),
  ];
}
