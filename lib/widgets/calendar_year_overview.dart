import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

class CalendarYearOverview extends StatelessWidget {
  final int year;
  final Set<DateTime> activeDays;
  final Function(DateTime) onMonthTap;

  const CalendarYearOverview({
    super.key,
    required this.year,
    required this.activeDays,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 Columns
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8, // Slightly taller for title + grid
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthDate = DateTime(year, index + 1);
        return _buildMiniMonth(context, monthDate);
      },
    );
  }

  Widget _buildMiniMonth(BuildContext context, DateTime monthDate) {
    final now = DateTime.now();
    final isCurrentMonth =
        monthDate.year == now.year && monthDate.month == now.month;

    return GestureDetector(
      onTap: () => onMonthTap(monthDate),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Title
          Text(
            _monthNames[monthDate.month - 1],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isCurrentMonth
                  ? GymTheme.colors.accent
                  : GymTheme.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Mini Grid (7x6)
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              // Determine days
              final days = _getDaysForMiniGrid(monthDate);
              // Tiny cells
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final date = days[index];
                  final isOutside = date.month != monthDate.month;
                  // Check activity (Time irrelevant for set check, key is Day)
                  // But activeDays contains DateTimes with time.
                  // Set check needs exact match? No, we need custom equality check or normalized date.
                  // CalendarService returns normalized Y-M-D.
                  final isEntry = !isOutside && _hasActivity(date);

                  if (isOutside) {
                    return const SizedBox(); // Invisible for cleaner look? Or muted?
                    // Hevy keeps it invisible or very faint. Let's make it empty/transparent
                  }

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isEntry
                          ? GymTheme.colors.accent
                          : GymTheme.colors.surfaceElevated
                              .withValues(alpha: 0.3),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _hasActivity(DateTime date) {
    // Check if set contains this day (CalendarService normalizes to 00:00:00)
    // We assume incoming dates are also normalized or we construct key
    final key = DateTime(date.year, date.month, date.day);
    return activeDays.contains(key);
  }

  List<DateTime> _getDaysForMiniGrid(DateTime month) {
    // Same logic as main calendar but strictly 6 rows logic if needed,
    // or just standard 35-42 cells.
    // Small grid: 7 cols.
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = first.weekday % 7; // Sun=0

    final days = <DateTime>[];

    // Padding
    for (int i = firstWeekday; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }
    // Days
    for (int i = 0; i < last.day; i++) {
      days.add(first.add(Duration(days: i)));
    }
    // End Padding (fill up to 42 for consistency, or 35)
    // 6 rows * 7 = 42
    while (days.length < 42) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    return days;
  }

  static const _monthNames = [
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
}
