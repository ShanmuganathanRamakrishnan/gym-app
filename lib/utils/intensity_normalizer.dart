import '../models/muscle_selector_mapping.dart';
import 'dart:math';

class IntensityNormalizer {
  /// Normalize raw set counts to 0.0 - 1.0 range
  ///
  /// Rules:
  /// - Highest muscle set count in the map becomes 1.0
  /// - 0 sets = 0.0
  /// - Non-zero values are clamped to minimum 0.2 visibility
  static Map<InternalMuscle, double> normalize(
      Map<InternalMuscle, double> rawData) {
    if (rawData.isEmpty) return {};

    // Find max sets to scale against
    double maxSets = 0;
    for (final count in rawData.values) {
      if (count > maxSets) maxSets = count;
    }

    if (maxSets == 0) return {};

    final Map<InternalMuscle, double> normalized = {};

    for (final entry in rawData.entries) {
      final muscle = entry.key;
      final count = entry.value;

      if (count <= 0) {
        normalized[muscle] = 0.0;
      } else {
        // Calculate relative intensity
        double intensity = count / maxSets;

        // Clamp minimum visibility to 0.2 (20% opacity/intensity) so it's visible
        // But true max should stay 1.0
        // Linear mapping from [0, 1] input (relative to max) to [0.2, 1.0] output?
        // Actually, just ensuring small values don't disappear.
        // Let's use simple max(0.2, intensity) logic.

        normalized[muscle] = max(0.2, intensity);
      }
    }

    return normalized;
  }
}
