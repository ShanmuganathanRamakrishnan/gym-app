import 'dart:math';
import 'package:flutter/material.dart';

class MuscleDistributionChart extends StatelessWidget {
  final Map<String, double> distribution;

  const MuscleDistributionChart({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text('No data', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    // Sort by value descending
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Donut Chart
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(160, 160),
                  painter: _DonutChartPainter(sortedEntries),
                ),
                // Optional: Total count in center? Hevy doesn't seem to have text in center in the screenshot.
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Legend
          Expanded(
            flex: 5,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedEntries.length,
              itemBuilder: (context, index) {
                final entry = sortedEntries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getColor(entry.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        // Display percentage or count? Screenshot shows "Chest (6) Other (3)". Absolute count.
                        // My distribution values are doubles (sets). Display as int if whole, or 1 decimal.
                        entry.value % 1 == 0
                            ? entry.value.toInt().toString()
                            : entry.value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  static Color _getColor(String key) {
    // Consistent colors?
    final hash = key.codeUnits.fold(0, (sum, c) => sum + c);
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.redAccent,
      Colors.tealAccent,
      Colors.amberAccent,
      Colors.indigoAccent,
    ];
    return colors[hash % colors.length];
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;

  _DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.85;
    const double strokeWidth = 24.0;

    final total = data.fold(0.0, (sum, e) => sum + e.value);
    if (total == 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -pi / 2;

    for (final entry in data) {
      final sweepAngle = (entry.value / total) * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = MuscleDistributionChart._getColor(entry.key);

      // Add slight gap if multiple segments
      final gap = data.length > 1 ? 0.05 : 0.0;

      canvas.drawArc(
          rect, startAngle + (gap / 2), sweepAngle - gap, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
