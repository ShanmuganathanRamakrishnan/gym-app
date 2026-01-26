import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';
import '../services/workout_history_service.dart';

/// Progress graph data aggregated per day
class _DayData {
  final DateTime date;
  final int volume; // total sets
  final int reps; // placeholder (not tracked yet)
  final int durationMinutes;

  _DayData({
    required this.date,
    this.volume = 0,
    this.reps = 0,
    this.durationMinutes = 0,
  });
}

/// Insight-driven progress graph with 7-day view
class ProfileProgressGraph extends StatefulWidget {
  final List<WorkoutHistoryEntry> recentWorkouts;

  const ProfileProgressGraph({
    super.key,
    required this.recentWorkouts,
  });

  @override
  State<ProfileProgressGraph> createState() => _ProfileProgressGraphState();
}

class _ProfileProgressGraphState extends State<ProfileProgressGraph> {
  int _selectedIndex = 2; // 0=Volume, 1=Reps, 2=Duration (default)

  static const _toggleLabels = ['Volume', 'Reps', 'Duration'];
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // Sprint B: Use Current Week (Mon-Sun) instead of Last 7 Days
  List<_DayData> _getCurrentWeekDays() {
    final now = DateTime.now();
    // Find Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = <_DayData>[];

    // Create map of existing workout data
    final Map<String, _DayData> dayMap = {};
    for (final workout in widget.recentWorkouts) {
      final key =
          '${workout.completedAt.year}-${workout.completedAt.month}-${workout.completedAt.day}';
      if (dayMap.containsKey(key)) {
        final existing = dayMap[key]!;
        dayMap[key] = _DayData(
          date: existing.date,
          volume: existing.volume + workout.totalSets,
          reps: existing
              .reps, // Reps still not in model? Assuming 0 works for now as per model
          durationMinutes:
              existing.durationMinutes + workout.duration.inMinutes,
        );
      } else {
        dayMap[key] = _DayData(
          date: workout.completedAt,
          volume: workout.totalSets,
          reps: 0,
          durationMinutes: workout.duration.inMinutes,
        );
      }
    }

    // Generate Mon-Sun
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      // Only include data if filtered workout actually matches typical criteria (handled by service usually)
      days.add(dayMap[key] ?? _DayData(date: date));
    }

    return days;
  }

  double _getValue(_DayData data) {
    switch (_selectedIndex) {
      case 0:
        return data.volume.toDouble();
      case 1:
        return data.reps.toDouble();
      case 2:
      default:
        return data.durationMinutes.toDouble();
    }
  }

  // Sprint C: Typography Polish
  Map<String, dynamic> _getInsightParts(List<_DayData> days) {
    final activeDays = days.where((d) => _getValue(d) > 0).length;

    if (activeDays == 0) {
      return {'prefix': 'No workouts this week', 'days': '', 'suffix': ''};
    }

    final total = days.fold<double>(0, (sum, d) => sum + _getValue(d));

    // Simple summary
    String prefix;
    switch (_selectedIndex) {
      case 0:
        prefix = '${total.toInt()} sets';
        break;
      case 1:
        prefix = '${total.toInt()} reps';
        break;
      default:
        final h = total ~/ 60;
        final m = total.toInt() % 60;
        prefix = h > 0 ? '${h}h ${m}m' : '${m}m';
    }

    return {
      'prefix': '$prefix • ',
      'days': '$activeDays',
      'suffix': ' active days',
    };
  }

  @override
  Widget build(BuildContext context) {
    final days = _getCurrentWeekDays();
    final hasAnyData = days.any((d) => _getValue(d) > 0);

    return Container(
      // Sprint A: Removing external margin as parent manages layout/padding
      // padding: EdgeInsets.all(GymTheme.spacing.md),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Toggle
          Padding(
            padding: EdgeInsets.all(GymTheme.spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Insight Text (Sprint C: Larger Typography)
                Builder(
                  builder: (context) {
                    final parts = _getInsightParts(days);
                    return RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: GymTheme.colors.textSecondary,
                          fontSize: 14, // Increased
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: parts['prefix'] as String),
                          TextSpan(
                            text: parts['days'] as String,
                            style: TextStyle(
                              color: GymTheme.colors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: parts['suffix'] as String),
                        ],
                      ),
                    );
                  },
                ),

                // Toggle Buttons (Simplified)
                Row(
                  children: List.generate(_toggleLabels.length, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: _selectedIndex == index
                                ? GymTheme.colors.accent.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _selectedIndex == index
                                    ? GymTheme.colors.accent
                                    : GymTheme.colors.textSecondary
                                        .withValues(alpha: 0.3))),
                        child: Text(
                          _toggleLabels[index],
                          style: TextStyle(
                              fontSize: 11,
                              color: _selectedIndex == index
                                  ? GymTheme.colors.accent
                                  : GymTheme.colors.textSecondary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }),
                )
              ],
            ),
          ),

          // Graph Area
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
              child: hasAnyData ? _buildGraph(days) : _buildEmptyState(),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildGraph(List<_DayData> days) {
    final values = days.map(_getValue).toList();
    // Sprint B: Normalize against strictly week max
    final maxValue = values.fold<double>(0, (max, v) => v > max ? v : max);

    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final value = values[index];
          final ratio = maxValue > 0 ? (value / maxValue) : 0.0;
          // Sprint C: Ensure sufficient opacity/contrast
          final isToday = days[index].date.day == DateTime.now().day;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: (constraints.maxWidth / 7) - 6,
                height: (constraints.maxHeight - 20) * ratio,
                constraints: const BoxConstraints(
                    minHeight: 4), // Min touch target/visibility
                decoration: BoxDecoration(
                  color: isToday
                      ? GymTheme.colors.accent
                      : GymTheme.colors.accent.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _weekdays[index],
                style: TextStyle(
                    fontSize: 10,
                    color: isToday ? Colors.white : GymTheme.colors.textMuted,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500),
              )
            ],
          );
        }),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart,
              size: 32, color: GymTheme.colors.surfaceElevated),
          const SizedBox(height: 8),
          Text(
            'No workouts this week',
            style: GymTheme.text.secondary.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
