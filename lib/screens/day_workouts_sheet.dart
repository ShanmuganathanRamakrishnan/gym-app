import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';
import '../services/workout_history_service.dart';

class DayWorkoutsSheet extends StatelessWidget {
  final DateTime date;
  final List<WorkoutHistoryEntry> workouts;

  const DayWorkoutsSheet({
    super.key,
    required this.date,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final int totalSets = workouts.fold(0, (sum, w) => sum + w.totalSets);
    final int totalMinutes =
        workouts.fold(0, (sum, w) => sum + w.duration.inMinutes);

    // Format Date: "Mon, Feb 24"
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dateString =
        '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';

    return Container(
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Text(
            dateString,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('${workouts.length} workouts',
                  style: TextStyle(color: GymTheme.colors.textSecondary)),
              _dotSeparator(),
              Text('$totalSets sets',
                  style: TextStyle(color: GymTheme.colors.textSecondary)),
              _dotSeparator(),
              Text('${totalMinutes}m duration',
                  style: TextStyle(color: GymTheme.colors.textSecondary)),
            ],
          ),

          const SizedBox(height: 24),

          // Workouts List
          if (workouts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No workouts logged',
                  style: TextStyle(color: GymTheme.colors.textMuted),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: GymTheme.colors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              workout.routineId != null
                                  ? 'Routine'
                                  : 'Freestyle',
                              style: TextStyle(
                                fontSize: 12,
                                color: GymTheme.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(workout.completedAt),
                        style: TextStyle(
                          color: GymTheme.colors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Safe bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _dotSeparator() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: GymTheme.colors.textMuted,
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
