import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';

class MuscleRadarChart extends StatelessWidget {
  final Map<String, double> normalizedData; // Values 0.0 - 1.0

  // Fixed visual order
  static const List<String> orderedAxes = [
    'CHEST',
    'SHOULDERS',
    'ARMS',
    'CORE',
    'QUADS',
    'HAMSTRINGS',
    'GLUTES',
    'BACK',
  ];

  const MuscleRadarChart({
    super.key,
    required this.normalizedData,
  }) : assert(normalizedData.length == 8, 'Data must have exactly 8 axes');

  @override
  Widget build(BuildContext context) {
    // Brand Color
    final accentColor = GymTheme.colors.accent; // Orange
    final gridColor = const Color(0xFF4A4A4A).withValues(alpha: 0.3);
    final labelColor = GymTheme.colors.textSecondary;

    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          // 4 Rings
          tickCount: 4,
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          gridBorderData: BorderSide(color: gridColor, width: 1),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: TextStyle(color: labelColor, fontSize: 10),

          // Data Sets
          dataSets: [
            // 1. Faint Baseline (Depth) - e.g. a 50% polygon or just specific rings
            // fl_chart draws rings based on tickCount automatically.
            // We can add a "full" phantom dataset for visual weight if desired,
            // but usually the grid is enough.
            // User requested "faint baseline polygon behind the data".
            // Let's add a dataset at constant 0.05 or similar if needed,
            // but standard radar grids usually suffice.
            // Requirement: "Always render a faint baseline polygon... behind data"
            // Let's assume this means a filled polygon at ~20-30% scale? or 100%?
            // "Visual depth" implies maybe a 'filled' background.
            // Let's try adding a small baseline filler or just rely on the grid
            // if "baseline polygon" means the grid itself.
            // Re-reading: "behind the data polygon".
            // Let's just create a dataset that is always 1.0 (full) but very low opacity?
            // That would create a filled background octagon.
            RadarDataSet(
              fillColor: const Color(0xFFFFFFFF).withValues(alpha: 0.02),
              borderColor: Colors.transparent,
              entryRadius: 0,
              dataEntries:
                  List.generate(8, (_) => const RadarEntry(value: 1.0)),
              borderWidth: 0,
            ),

            // 2. Actual Data
            RadarDataSet(
              fillColor: accentColor.withValues(alpha: 0.35), // Updated opacity
              borderColor: accentColor,
              entryRadius: 2, // Small dots at vertices
              dataEntries: orderedAxes.map((axisKey) {
                // Ensure we get the value for the specific ordered key
                // Keys in map expected to match orderedAxes strings
                final value = normalizedData[axisKey] ?? 0.0;
                return RadarEntry(value: value);
              }).toList(),
              borderWidth: 2,
            ),
          ],

          // Axes Titles
          getTitle: (index, angle) {
            if (index >= orderedAxes.length) {
              return const RadarChartTitle(text: '');
            }
            return RadarChartTitle(text: orderedAxes[index]);
          },
        ),
      ),
    );
  }
}
