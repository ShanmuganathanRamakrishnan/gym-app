import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

/// Compact stats row with 3 small chips (Workouts, Streak, Time)
class ProfileCompactStats extends StatelessWidget {
  final int workoutCount;
  final int currentStreak;
  final int totalMinutes;

  const ProfileCompactStats({
    super.key,
    required this.workoutCount,
    required this.currentStreak,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
      child: Row(
        children: [
          Expanded(
              child: _buildChip(
                  Icons.fitness_center, '$workoutCount', 'Workouts')),
          SizedBox(width: GymTheme.spacing.sm),
          Expanded(
              child: _buildChip(
                  Icons.local_fire_department, '$currentStreak', 'Streak')),
          SizedBox(width: GymTheme.spacing.sm),
          Expanded(child: _buildChip(Icons.schedule, _formatTime(), 'Time')),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String value, String label) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 10, horizontal: GymTheme.spacing.sm),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.card),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: GymTheme.colors.accent),
              const SizedBox(width: 4),
              Text(
                value,
                style: GymTheme.text.body.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GymTheme.text.secondary.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _formatTime() {
    if (totalMinutes < 60) {
      return '${totalMinutes}m';
    }
    final hours = totalMinutes ~/ 60;
    return '${hours}h';
  }
}
