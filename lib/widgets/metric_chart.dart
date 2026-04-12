// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/measurement.dart';
import '../theme/gym_theme.dart';

class MetricChart extends StatelessWidget {
  final List<Measurement> data; // Assumed sorted by date
  final MeasurementMetric metric;
  final String unit;

  const MetricChart({
    super.key,
    required this.data,
    required this.metric,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return Center(
        child: Text(
          'Not enough data for chart',
          style: TextStyle(color: GymTheme.colors.textMuted),
        ),
      );
    }

    // Extract spots
    final spots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < data.length; i++) {
      final value = data[i].metrics.getValue(metric);
      if (value != null) {
        // X is index for simplicity in this MVP (equidistant visual steps usually better for trends than strict time scaling unless gaps are huge)
        // Refinement: Request implied "Time" on X. But `fl_chart` with Dates is tricky.
        // Let's use Index (0 to N) but show Dates in Tooltip/Axis.
        // Actually, strictly time-scaled is better for "truth".
        // Let's use milliseconds epoch for X, and format axis.
        final x = data[i].date.millisecondsSinceEpoch.toDouble();
        spots.add(FlSpot(x, value));

        if (value < minY) {
          minY = value;
        }
        if (value > maxY) {
          maxY = value;
        }
      }
    }

    if (spots.isEmpty) {
      return Center(
        child: Text('No data for this metric',
            style: TextStyle(color: GymTheme.colors.textMuted)),
      );
    }

    // Padding for Y axis
    final yRange = maxY - minY;
    final padding = yRange == 0 ? 1.0 : yRange * 0.1;
    minY -= padding;
    maxY += padding;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4, // 4 lines
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: GymTheme.colors.border,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _calculateInterval(spots.first.x, spots.last.x),
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MMM d').format(date),
                    style: TextStyle(
                        color: GymTheme.colors.textMuted, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                  showTitles: false)), // Clean look, value in tooltip
        ),
        borderData: FlBorderData(show: false),
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: GymTheme.colors.accent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: GymTheme.colors.accent.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => GymTheme.colors.surfaceElevated,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final val = spot.y.toStringAsFixed(1);
                final date =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                final dateStr = DateFormat('MMM d').format(date);
                return LineTooltipItem(
                  '$val $unit\n$dateStr',
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _calculateInterval(double min, double max) {
    // Attempt to show ~5 labels
    final diff = max - min;
    if (diff == 0) {
      return 1;
    }
    return diff / 4;
  }
}
