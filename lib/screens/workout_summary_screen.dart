import 'package:flutter/material.dart';
import '../main.dart';
import '../models/workout_session.dart';
import '../models/routine.dart';
import '../services/routine_store.dart';
import 'create_routine_screen.dart';

/// Workout completion summary screen
class WorkoutSummaryScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSummaryScreen({super.key, required this.session});

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours hr ${minutes.toString().padLeft(2, '0')} min';
    } else if (minutes > 0) {
      return '$minutes min ${seconds.toString().padLeft(2, '0')} sec';
    }
    return '$seconds sec';
  }

  void _finish(BuildContext context) {
    // Pop back to workout tab
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _saveAsRoutine(BuildContext context) async {
    // Convert session exercises to routine exercises
    final routineExercises = session.exercises.map((e) {
      return RoutineExercise(
        exerciseId: e.exerciseId,
        name: e.name,
        sets: e.sets.length,
        reps: e.sets.isNotEmpty && e.sets.first.reps > 0
            ? e.sets.first.reps.toString()
            : '8-12',
      );
    }).toList();

    // Navigate to create routine with prefilled exercises
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateRoutineScreen(
          prefillExercises: routineExercises,
          prefillName: session.name == 'Freestyle Workout' ? '' : session.name,
        ),
      ),
    );

    if (result == true && context.mounted) {
      // Ensure RoutineStore is refreshed
      await RoutineStore().refresh();
      // Pop back to workout tab
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedExercises = session.exercises
        .where((e) => !e.skipped && e.completedSetsCount > 0)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Success icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.accentDim,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.celebration_outlined,
                        color: AppColors.accent,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Workout Complete!',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session.name,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Stats row
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            icon: Icons.timer_outlined,
                            value: _formatDuration(session.totalDuration),
                            label: 'Duration',
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: AppColors.surfaceLight,
                          ),
                          _StatItem(
                            icon: Icons.fitness_center,
                            value: '${completedExercises.length}',
                            label: 'Exercises',
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: AppColors.surfaceLight,
                          ),
                          _StatItem(
                            icon: Icons.check_circle_outline,
                            value: '${session.totalSetsCompleted}',
                            label: 'Sets',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Exercise list
                    if (completedExercises.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Exercises Completed',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...completedExercises.map((exercise) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentDim,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.accent,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${exercise.completedSetsCount}/${exercise.sets.length} sets completed',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom CTAs
            _buildBottomCTAs(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCTAs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceLight)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary: Finish
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _finish(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Finish',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),

          // Secondary: Save as Routine (only for freestyle)
          if (session.isFreestyle && session.exercises.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _saveAsRoutine(context),
                icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                label: const Text('Save as Routine'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.surfaceLight),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
