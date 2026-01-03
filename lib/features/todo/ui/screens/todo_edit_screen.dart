import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/providers/settings_provider.dart';
import '../../data/models/todo.dart';
import '../../providers/category_provider.dart';
import '../../providers/todo_provider.dart';
import '../widgets/image_attachment_field.dart';

class TodoEditScreen extends ConsumerStatefulWidget {
  const TodoEditScreen({super.key, this.todo});

  final Todo? todo;

  @override
  ConsumerState<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends ConsumerState<TodoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _selectedCategoryId;
  DateTime? _dueDate;
  String? _imagePath;
  String? _newImagePath;
  bool _removeImage = false;

  bool get isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');
    // Use default category from settings for new todos
    _selectedCategoryId = widget.todo?.categoryId ??
        ref.read(defaultCategoryIdProvider);
    _dueDate = widget.todo?.dueDate;
    _imagePath = widget.todo?.imagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (isEditing) {
      await ref.read(todosProvider.notifier).updateTodo(
            widget.todo!.copyWith(
              title: title,
              description: description.isEmpty ? null : description,
              categoryId: _selectedCategoryId,
              dueDate: _dueDate,
            ),
            newImagePath: _newImagePath,
            removeImage: _removeImage,
          );
    } else {
      await ref.read(todosProvider.notifier).addTodo(
            title: title,
            description: description.isEmpty ? null : description,
            categoryId: _selectedCategoryId,
            dueDate: _dueDate,
            imagePath: _newImagePath,
          );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(todosProvider.notifier).deleteTodo(widget.todo!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            Semantics(
              identifier: 'delete-button',
              label: 'Delete todo',
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                  ),
                  onPressed: _delete,
                  tooltip: 'Delete',
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title field
            _buildSectionLabel(theme, 'Title', Icons.edit_rounded),
            const SizedBox(height: 8),
            Semantics(
              identifier: 'title-field',
              label: 'Todo title',
              child: TextFormField(
                controller: _titleController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 24),

            // Description field
            _buildSectionLabel(theme, 'Description', Icons.notes_rounded),
            const SizedBox(height: 8),
            Semantics(
              identifier: 'description-field',
              label: 'Todo description',
              child: TextFormField(
                controller: _descriptionController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Add some details...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 24),

            // Category selection
            _buildSectionLabel(theme, 'Category', Icons.label_outline_rounded),
            const SizedBox(height: 12),
            Semantics(
              identifier: 'category-dropdown',
              label: 'Select category',
              child: categories.when(
                data: (cats) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildCategoryOption(
                      theme,
                      null,
                      'None',
                      null,
                      _selectedCategoryId == null,
                    ),
                    ...cats.map((cat) => _buildCategoryOption(
                          theme,
                          cat.id,
                          cat.name,
                          cat.color,
                          _selectedCategoryId == cat.id,
                        )),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 24),

            // Due date picker
            _buildSectionLabel(theme, 'Due Date', Icons.calendar_today_rounded),
            const SizedBox(height: 8),
            Semantics(
              identifier: 'due-date-picker',
              label: 'Select due date',
              child: GestureDetector(
                onTap: _selectDueDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: _dueDate != null
                        ? Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _dueDate != null
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.event_rounded,
                          size: 20,
                          color: _dueDate != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dueDate != null
                              ? _formatDate(_dueDate!)
                              : 'No due date',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _dueDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.outline,
                          ),
                        ),
                      ),
                      if (_dueDate != null)
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.outline,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _dueDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Image attachment
            _buildSectionLabel(theme, 'Attachment', Icons.image_rounded),
            const SizedBox(height: 8),
            ImageAttachmentField(
              imagePath: _removeImage ? null : (_newImagePath ?? _imagePath),
              onImageSelected: (path) {
                setState(() {
                  _newImagePath = path;
                  _removeImage = false;
                });
              },
              onImageRemoved: () {
                setState(() {
                  _newImagePath = null;
                  _removeImage = true;
                });
              },
            ),
            const SizedBox(height: 40),

            // Save button
            Semantics(
              identifier: 'save-button',
              label: 'Save todo',
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEditing ? Icons.check_rounded : Icons.add_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Update Task' : 'Create Task',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryOption(
    ThemeData theme,
    String? id,
    String name,
    Color? color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? theme.colorScheme.primary).withOpacity(0.15)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (color ?? theme.colorScheme.primary)
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? (color ?? theme.colorScheme.primary)
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.check_rounded,
                size: 14,
                color: color ?? theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
