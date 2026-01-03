import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageAttachmentField extends StatelessWidget {
  const ImageAttachmentField({
    super.key,
    required this.imagePath,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  final String? imagePath;
  final ValueChanged<String> onImageSelected;
  final VoidCallback onImageRemoved;

  Future<void> _showImageSourceDialog(BuildContext context) async {
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Image',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Semantics(
                identifier: 'image-source-camera',
                label: 'Take photo',
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: const Text('Take Photo'),
                  subtitle: Text(
                    'Use camera to capture an image',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ),
              Semantics(
                identifier: 'image-source-gallery',
                label: 'Choose from gallery',
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: Text(
                    'Select an existing image',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      onImageSelected(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imagePath != null;

    return Semantics(
      identifier: 'image-attachment-field',
      label: hasImage ? 'Attached image' : 'Attach image',
      child: GestureDetector(
        onTap: () => _showImageSourceDialog(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: hasImage ? 200 : 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasImage
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: hasImage
              ? _buildImagePreview(context, theme)
              : _buildPlaceholder(theme),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_photo_alternate_rounded,
              size: 28,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to add image',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Semantics(
          identifier: 'image-preview',
          label: 'Attached image preview',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              File(imagePath!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              // Change image button
              _buildActionButton(
                theme: theme,
                icon: Icons.edit_rounded,
                tooltip: 'Change image',
                onTap: () => _showImageSourceDialog(context),
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              // Remove image button
              Semantics(
                identifier: 'image-remove-button',
                label: 'Remove image',
                child: _buildActionButton(
                  theme: theme,
                  icon: Icons.close_rounded,
                  tooltip: 'Remove image',
                  onTap: onImageRemoved,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
