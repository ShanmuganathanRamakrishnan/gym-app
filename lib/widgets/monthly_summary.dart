import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

class MonthlySummary extends StatelessWidget {
  final int workouts;
  final int sets;
  final int durationMinutes;

  const MonthlySummary({
    super.key,
    required this.workouts,
    required this.sets,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(GymTheme.spacing.md),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.card),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month',
            style: GymTheme.text.cardTitle,
          ),
          SizedBox(height: GymTheme.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                  'Workouts', workouts.toString(), Icons.fitness_center),
              _buildMetric('Total Sets', sets.toString(), Icons.layers),
              _buildMetric('Hours', (durationMinutes / 60).toStringAsFixed(1),
                  Icons.timer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: GymTheme.colors.accent, size: 24),
        SizedBox(height: GymTheme.spacing.sm),
        Text(
          value,
          style: TextStyle(
            color: GymTheme.colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: GymTheme.spacing.xs),
        Text(
          label,
          style: GymTheme.text.secondary,
        ),
      ],
    );
  }
}
