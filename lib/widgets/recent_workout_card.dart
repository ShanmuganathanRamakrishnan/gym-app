import 'package:flutter/material.dart';
import 'profile_header.dart' show ProfileColors;
import '../services/workout_history_service.dart';

/// Recent workout summary card with "View all" action
class RecentWorkoutCard extends StatelessWidget {
  final WorkoutHistoryEntry? recentWorkout;
  final VoidCallback? onViewAllTap;

  const RecentWorkoutCard({
    super.key,
    this.recentWorkout,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewAllTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ProfileColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    recentWorkout != null
                        ? Icons.history
                        : Icons.fitness_center_outlined,
                    color: ProfileColors.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: recentWorkout != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Most recent',
                              style: TextStyle(
                                color: ProfileColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _buildWorkoutSummary(),
                              style: const TextStyle(
                                color: ProfileColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      : const Text(
                          'No workouts yet',
                          style: TextStyle(
                            color: ProfileColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                ),

                // Chevron
                const Icon(
                  Icons.chevron_right,
                  color: ProfileColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildWorkoutSummary() {
    if (recentWorkout == null) return '';
    final workout = recentWorkout!;
    final name = workout.name;
    final date = _formatDate(workout.completedAt);
    final duration = _formatDuration(workout.duration);
    return '$name • $date • $duration';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }

  String _formatDuration(Duration duration) {
    final mins = duration.inMinutes;
    if (mins < 60) return '${mins}m';
    final hours = mins ~/ 60;
    final remainMins = mins % 60;
    return remainMins > 0 ? '${hours}h ${remainMins}m' : '${hours}h';
  }
}
