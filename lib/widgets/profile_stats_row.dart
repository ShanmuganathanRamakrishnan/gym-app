import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

/// Stats row with selectable chips (Duration | Volume | Reps)
class ProfileStatsRow extends StatelessWidget {
  final int totalMinutes;
  final int totalSets;
  final int totalReps;
  final int selectedIndex;
  final ValueChanged<int>? onChipSelected;

  const ProfileStatsRow({
    super.key,
    required this.totalMinutes,
    required this.totalSets,
    this.totalReps = 0,
    this.selectedIndex = 0,
    this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
      padding: EdgeInsets.all(GymTheme.spacing.md),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.lg),
      ),
      child: Column(
        children: [
          // Chart placeholder
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: GymTheme.colors.surfaceElevated,
              borderRadius: BorderRadius.circular(GymTheme.radius.sm),
            ),
            child: Center(
              child: Icon(
                Icons.show_chart,
                size: 32,
                color: GymTheme.colors.textMuted,
              ),
            ),
          ),
          SizedBox(height: GymTheme.spacing.md),

          // Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildChip(0, 'Duration', _formatDuration(totalMinutes)),
              _buildChip(1, 'Volume', '$totalSets sets'),
              _buildChip(2, 'Reps', '$totalReps'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(int index, String label, String value) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onChipSelected?.call(index),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: GymTheme.spacing.md, vertical: GymTheme.spacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? GymTheme.colors.accent
              : GymTheme.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: isSelected ? Colors.white : GymTheme.colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : GymTheme.colors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}
