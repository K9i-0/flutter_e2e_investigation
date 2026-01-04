import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../data/models/category.dart';
import '../../data/models/todo.dart';

class TodoTile extends StatefulWidget {
  const TodoTile({
    super.key,
    required this.todo,
    this.category,
    required this.onToggleCompleted,
    required this.onTap,
  });

  final Todo todo;
  final Category? category;
  final VoidCallback onToggleCompleted;
  final VoidCallback onTap;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todo = widget.todo;
    final category = widget.category;

    return Semantics(
      identifier: 'todo-tile-${todo.id}',
      label: todo.title,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()..scaleByVector3(Vector3(_isPressed ? 0.98 : 1.0, _isPressed ? 0.98 : 1.0, 1.0)),
          transformAlignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: todo.isCompleted
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Semantics(
                  identifier: 'todo-checkbox-${todo.id}',
                  label: 'Mark ${todo.title} as done',
                  child: GestureDetector(
                    onTap: widget.onToggleCompleted,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: todo.isCompleted
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: todo.isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: todo.isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: theme.textTheme.titleMedium!.copyWith(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: theme.colorScheme.outline,
                          color: todo.isCompleted
                              ? theme.colorScheme.outline
                              : theme.colorScheme.onSurface,
                        ),
                        child: Text(todo.title),
                      ),
                      // Description
                      if (todo.description != null &&
                          todo.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            todo.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      // Category and due date row
                      if (category != null || todo.dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (category != null)
                                _buildCategoryBadge(theme, category),
                              if (todo.dueDate != null)
                                _buildDueDateBadge(theme, todo.dueDate!),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Thumbnail (if image attached)
                if (todo.imagePath != null) ...[
                  const SizedBox(width: 12),
                  Semantics(
                    identifier: 'todo-thumbnail-${todo.id}',
                    label: 'Attached image',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(todo.imagePath!),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 20,
                              color: theme.colorScheme.outline,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ThemeData theme, Category category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: category.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateBadge(ThemeData theme, DateTime dueDate) {
    final color = _getDueDateColor(theme, dueDate);
    final isOverdue = _isOverdue(dueDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            _formatDueDate(dueDate),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isBefore(today);
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

    final diff = dateOnly.difference(today).inDays;
    if (diff > 0 && diff <= 7) return 'In $diff days';
    if (diff < 0 && diff >= -7) return '${-diff} days ago';

    return '${date.month}/${date.day}';
  }

  Color _getDueDateColor(ThemeData theme, DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dateOnly.isBefore(today)) {
      return theme.colorScheme.error;
    }
    if (dateOnly == today) {
      return theme.colorScheme.tertiary;
    }
    return theme.colorScheme.secondary;
  }
}
