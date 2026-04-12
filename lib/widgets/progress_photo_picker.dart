import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/gym_theme.dart';

class ProgressPhotoPicker extends StatelessWidget {
  final List<String> photoPaths; // Local paths
  final Function(String) onPhotoAdded;
  final Function(String) onPhotoRemoved;
  final int maxVisible;

  const ProgressPhotoPicker({
    super.key,
    required this.photoPaths,
    required this.onPhotoAdded,
    required this.onPhotoRemoved,
    this.maxVisible = 4,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1080, // Compression guardrail
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        onPhotoAdded(image.path);
      }
    } catch (e) {
      // Handle error cleanly
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GymTheme.colors.surface,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Take Photo',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Choose from Gallery',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no photos, show a simple "Add Photo" button row
    if (photoPaths.isEmpty) {
      return GestureDetector(
        onTap: () => _showSourceSheet(context),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: GymTheme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GymTheme.colors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, color: GymTheme.colors.textMuted),
              const SizedBox(height: 4),
              Text('Add Photo',
                  style: TextStyle(
                      color: GymTheme.colors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    // Grid layout
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoPaths.length + 1, // +1 for Add button
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == photoPaths.length) {
            // Add Button
            return GestureDetector(
              onTap: () => _showSourceSheet(context),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: GymTheme.colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GymTheme.colors.border),
                ),
                child: Center(
                  child: Icon(Icons.add, color: GymTheme.colors.textSecondary),
                ),
              ),
            );
          }

          // Photo Thumbnail
          final path = photoPaths[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[900],
                      child:
                          const Icon(Icons.broken_image, color: Colors.white)),
                ),
              ),
              // Delete X
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onPhotoRemoved(path),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
