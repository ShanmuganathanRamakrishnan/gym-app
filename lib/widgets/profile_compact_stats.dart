import 'package:flutter/material.dart';
import 'profile_header.dart' show ProfileColors;

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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
              child: _buildChip(
                  Icons.fitness_center, '$workoutCount', 'Workouts')),
          const SizedBox(width: 8),
          Expanded(
              child: _buildChip(
                  Icons.local_fire_department, '$currentStreak', 'Streak')),
          const SizedBox(width: 8),
          Expanded(child: _buildChip(Icons.schedule, _formatTime(), 'Time')),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: ProfileColors.accent),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  color: ProfileColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: ProfileColors.textMuted,
              fontSize: 10,
            ),
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
