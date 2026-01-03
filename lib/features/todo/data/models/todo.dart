import 'package:flutter/foundation.dart';

@immutable
class Todo {
  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.categoryId,
    this.dueDate,
    this.imagePath,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? categoryId;
  final DateTime? dueDate;
  final String? imagePath;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    DateTime? dueDate,
    String? imagePath,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearImagePath = false,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'dueDate': dueDate?.toIso8601String(),
      'imagePath': imagePath,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      imagePath: json['imagePath'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
