import 'package:flutter/material.dart';
import '../services/muscle_stats_service.dart';
import '../theme/gym_theme.dart';

class MainExercisesList extends StatelessWidget {
  final List<ExerciseStat> exercises;

  const MainExercisesList({super.key, required this.exercises});

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
            'Top Exercises',
            style: GymTheme.text.cardTitle,
          ),
          SizedBox(height: GymTheme.spacing.md),
          if (exercises.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: GymTheme.spacing.sm),
                child: Text('No data', style: GymTheme.text.secondary),
              ),
            ),
          ...exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: GymTheme.spacing.sm),
              child: Row(
                children: [
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: GymTheme.colors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: GymTheme.spacing.md),
                  Expanded(
                    child: Text(
                      item.name,
                      style: GymTheme.text.body.copyWith(
                        color: GymTheme.colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${item.totalSets} sets',
                    style: GymTheme.text.secondary,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
