import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/gym_theme.dart';

/// Avatar picker widget with camera/gallery support.
///
/// Displays a circular avatar with an orange ring and "Change Picture" link.
/// Uses image_picker for photo selection.
class AvatarPicker extends StatelessWidget {
  final String? currentPath;
  final ValueChanged<String?> onChanged;
  final double size;

  const AvatarPicker({
    super.key,
    this.currentPath,
    required this.onChanged,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with orange ring
        GestureDetector(
          onTap: () => _showPickerOptions(context),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: GymTheme.colors.accent,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _buildAvatarContent(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Change Picture link
        GestureDetector(
          onTap: () => _showPickerOptions(context),
          child: Text(
            'Change Picture',
            style: TextStyle(
              fontSize: 14,
              color: GymTheme.colors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (currentPath != null && currentPath!.isNotEmpty) {
      final file = File(currentPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: size,
          height: size,
        );
      }
    }

    // Default avatar placeholder
    return Container(
      color: GymTheme.colors.surfaceElevated,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: GymTheme.colors.textMuted,
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GymTheme.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: GymTheme.colors.accent),
                title: Text(
                  'Take Photo',
                  style: TextStyle(color: GymTheme.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: GymTheme.colors.accent),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(color: GymTheme.colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (currentPath != null && currentPath!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onChanged(null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        onChanged(picked.path);
      }
    } catch (e) {
      // Handle permission denied or picker error silently
    }
  }
}
