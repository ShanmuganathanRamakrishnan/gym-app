import 'package:flutter/material.dart';
import 'profile_header.dart' show ProfileColors;

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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Chart placeholder
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: ProfileColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.show_chart,
                size: 32,
                color: ProfileColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 16),

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ProfileColors.accent : ProfileColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: isSelected ? Colors.white : ProfileColors.textPrimary,
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
                    : ProfileColors.textMuted,
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
