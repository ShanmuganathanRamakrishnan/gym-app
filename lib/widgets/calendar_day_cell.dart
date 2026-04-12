import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isOutsideMonth;
  final int workoutCount;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    this.isToday = false,
    this.isSelected = false,
    this.isOutsideMonth = false,
    this.workoutCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Maximum dots to show
    final int dotsToShow = workoutCount > 3 ? 3 : workoutCount;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isToday
              ? Border.all(color: GymTheme.colors.accent, width: 2)
              : null,
          color: isSelected
              ? GymTheme.colors.surfaceElevated
              : Colors.transparent, // Transient state
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: isOutsideMonth
                    ? GymTheme.colors.textMuted
                    : GymTheme.colors.textPrimary,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (dotsToShow > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(dotsToShow, (index) {
                  return Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isOutsideMonth
                          ? GymTheme.colors.textMuted // Should dim dots too
                          : GymTheme.colors.accent,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ] else
              // Placeholder to keep alignment consistent if needed, or just let it center
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
