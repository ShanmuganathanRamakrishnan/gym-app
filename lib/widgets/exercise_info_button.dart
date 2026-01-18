import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/exercise_demo_modal.dart';

/// Small info button to be added next to exercise names
class ExerciseInfoButton extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;
  final double size;

  const ExerciseInfoButton({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showExerciseDemoModal(context, exerciseId, exerciseName),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.info_outline,
          size: size,
          color: AppColors.textMuted,
          semanticLabel: 'View exercise info for $exerciseName',
        ),
      ),
    );
  }
}
