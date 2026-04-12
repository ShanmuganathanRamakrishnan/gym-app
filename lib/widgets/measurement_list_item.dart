import 'package:flutter/material.dart';
import '../models/measurement.dart';
import '../theme/gym_theme.dart';
import 'package:intl/intl.dart';

class MeasurementListItem extends StatelessWidget {
  final Measurement measurement;
  final VoidCallback onTap;

  const MeasurementListItem({
    super.key,
    required this.measurement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format Date: "Oct 24, 2023"
    final dateStr = DateFormat.yMMMd().format(measurement.date);

    // Determine preview string (Top 2 metrics)
    final metricsText = _buildMetricsPreview(measurement.metrics);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GymTheme.colors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Date & Metrics
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (metricsText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      metricsText,
                      style: TextStyle(
                        color: GymTheme.colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: GymTheme.colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  String _buildMetricsPreview(MeasurementMetrics metrics) {
    final parts = <String>[];

    // Priority 1: Weight
    if (metrics.weightKg != null) {
      parts.add('${metrics.weightKg} kg');
    }

    // Priority 2: Body Fat
    if (metrics.bodyFatPercent != null) {
      parts.add('${metrics.bodyFatPercent}% BF');
    }

    // Priority 3: Waist (Only if we have space, i.e., < 2 items)
    if (parts.length < 2 && metrics.waistCm != null) {
      parts.add('${metrics.waistCm} cm Waist');
    }

    // If still < 2, maybe add one more?
    // Request technically said "Weight, then Body Fat %, then Waist".
    // It didn't strictly say "Only 2". But "preview" usually implies concise.
    // Let's stick to max 2 items joined by " • "

    return parts.take(2).join(' • ');
  }
}
