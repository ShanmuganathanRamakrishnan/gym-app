import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

class WeekNavigator extends StatelessWidget {
  final DateTime currentWeekStart;
  final VoidCallback onPreviousTap;
  final VoidCallback onNextTap;
  final bool canGoNext; // True if not in current week
  final bool compact; // For potential reuse in smaller spaces

  const WeekNavigator({
    super.key,
    required this.currentWeekStart,
    required this.onPreviousTap,
    required this.onNextTap,
    this.canGoNext = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Format: "MMM d - MMM d, YYYY"
    // e.g. "Jun 1 - Jun 7, 2024"
    final endOfWeek = currentWeekStart.add(const Duration(days: 6));

    final startStr = _formatDate(currentWeekStart);
    final endStr = _formatDate(endOfWeek);
    final year = currentWeekStart.year;

    final label = "$startStr - $endStr, $year";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPreviousTap,
          icon: Icon(Icons.chevron_left,
              color: GymTheme.colors.textPrimary, size: 28),
          splashRadius: 24,
        ),
        SizedBox(width: GymTheme.spacing.sm),
        Text(
          label,
          style: GymTheme.text.sectionTitle.copyWith(fontSize: 16),
        ),
        SizedBox(width: GymTheme.spacing.sm),
        IconButton(
          onPressed: canGoNext ? onNextTap : null,
          icon: Icon(Icons.chevron_right,
              color: canGoNext
                  ? GymTheme.colors.textPrimary
                  : GymTheme.colors.textMuted,
              size: 28),
          splashRadius: 24,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return "${months[date.month - 1]} ${date.day}";
  }
}
