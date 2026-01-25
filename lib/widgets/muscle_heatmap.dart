import 'package:flutter/material.dart';
import '../models/muscle_selector_mapping.dart';
import 'vendor/muscle_selector/muscle_map.dart';

class MuscleHeatmap extends StatelessWidget {
  final Map<InternalMuscle, double> normalizedIntensities;
  final Function(InternalMuscle)? onMuscleTap;

  const MuscleHeatmap({
    super.key,
    required this.normalizedIntensities,
    this.onMuscleTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Convert normalized intensities to Color Map
    final Map<String, Color> colorMap = {};

    for (final entry in normalizedIntensities.entries) {
      final muscle = entry.key;
      final intensity = entry.value; // 0.0 to 1.0

      if (intensity > 0) {
        // Resolve ID
        final id = muscleSelectorIdMap[muscle];
        if (id != null) {
          colorMap[id] = _getColorForIntensity(intensity);
        }
      }
    }

    // 2. Render MuscleMap
    return AspectRatio(
      aspectRatio: 0.58, // Tweaked for svg human body ratio
      child: MuscleMap(
        colorMap: colorMap,
        width: double.infinity,
        height: double.infinity,
        defaultColor: const Color(0xFF2A2A2A), // Dark grey for neutral
        strokeColor: const Color(0xFF111111), // Darker stroke
        onMuscleTap: (id) {
          if (onMuscleTap == null) return;
          // Reverse lookup ID to InternalMuscle
          // We can use the map entries
          final entry = muscleSelectorIdMap.entries.firstWhere(
              (e) => e.value == id,
              orElse: () => const MapEntry(InternalMuscle.other, ''));

          if (entry.key != InternalMuscle.other) {
            onMuscleTap!(entry.key);
          }
        },
      ),
    );
  }

  Color _getColorForIntensity(double intensity) {
    // Brand Color: #FC4C02
    // Scale opacity or mix with white/red?
    // Hevy uses gradients of orange/red.

    // Low intensity (0.2) -> Darkish Orange
    // High intensity (1.0) -> Bright Neon Orange

    // Base: Color(0xFFFC4C02)
    // We can use withValues alpha, but that shows background.
    // Better to mix colors.

    const baseColor = Color(0xFFFC4C02);

    // Opacity approach (simplest for heatmap feel over dark bg)
    // Intensity is clamped to 0.2 min in normalizer.
    return baseColor.withValues(alpha: intensity);
  }
}
