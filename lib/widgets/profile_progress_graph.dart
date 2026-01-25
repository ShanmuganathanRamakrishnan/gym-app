import 'package:flutter/material.dart';
import 'profile_header.dart' show ProfileColors;
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
  static const _unitLabels = [
    'Volume (sets)',
    'Reps (total)',
    'Duration (min)'
  ];
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  /// Generate last 7 days with data filled in
  List<_DayData> _getLast7Days() {
    final now = DateTime.now();
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
          reps: existing.reps,
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

    // Generate last 7 days (oldest first)
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
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

  /// Generate insight parts for RichText
  Map<String, dynamic> _getInsightParts(List<_DayData> days) {
    final activeDays = days.where((d) => _getValue(d) > 0).length;

    if (activeDays == 0) {
      return {
        'prefix': 'Start your first workout this week',
        'days': '',
        'suffix': ''
      };
    }

    final total = days.fold<double>(0, (sum, d) => sum + _getValue(d));
    final todayValue = _getValue(days.last);

    String prefix;
    // Check if today had activity
    if (todayValue > 0) {
      switch (_selectedIndex) {
        case 0:
          prefix = '${todayValue.toInt()} sets today • ';
          break;
        case 1:
          prefix = '${todayValue.toInt()} reps today • ';
          break;
        case 2:
        default:
          prefix = '${todayValue.toInt()} min today • ';
          break;
      }
    } else {
      // Weekly summary
      switch (_selectedIndex) {
        case 0:
          prefix = '${total.toInt()} sets this week • ';
          break;
        case 1:
          prefix = '${total.toInt()} reps this week • ';
          break;
        case 2:
        default:
          final hours = total ~/ 60;
          final mins = total.toInt() % 60;
          if (hours > 0) {
            prefix = '${hours}h ${mins}m this week • ';
          } else {
            prefix = '${total.toInt()} min this week • ';
          }
          break;
      }
    }

    return {
      'prefix': prefix,
      'days': '$activeDays',
      'suffix': ' active days',
    };
  }

  @override
  Widget build(BuildContext context) {
    final days = _getLast7Days();
    final hasAnyData = days.any((d) => _getValue(d) > 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle buttons
          Row(
            children: List.generate(_toggleLabels.length, (index) {
              final isSelected = index == _selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ProfileColors.accent
                          : ProfileColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _toggleLabels[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : ProfileColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 4),

          // Unit label
          Center(
            child: Text(
              _unitLabels[_selectedIndex],
              style: const TextStyle(
                color: ProfileColors.textMuted,
                fontSize: 10,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Insight line with highlighted days
          Builder(
            builder: (context) {
              final parts = _getInsightParts(days);
              return RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: ProfileColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: parts['prefix'] as String),
                    TextSpan(
                      text: parts['days'] as String,
                      style: const TextStyle(
                        color: ProfileColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: parts['suffix'] as String),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Graph area with bars
          SizedBox(
            height: 100,
            child: hasAnyData ? _buildGraph(days) : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildGraph(List<_DayData> days) {
    final values = days.map(_getValue).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // Bars with subtle grid lines
        Expanded(
          child: Stack(
            children: [
              // Grid lines (rendered below bars)
              Positioned.fill(
                child: Column(
                  children: [
                    // 33% from top (66% height)
                    const Spacer(flex: 1),
                    Container(
                      height: 1,
                      color: ProfileColors.textSecondary.withValues(alpha: 0.1),
                    ),
                    // 66% from top (33% height)
                    const Spacer(flex: 1),
                    Container(
                      height: 1,
                      color: ProfileColors.textSecondary.withValues(alpha: 0.1),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
              // Bars (rendered above grid)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final value = values[index];
                  final height = maxValue > 0 ? (value / maxValue) * 80 : 0.0;
                  final hasValue = value > 0;
                  final isToday = index == 6;

                  // Determine bar color with proper emphasis
                  Color barColor;
                  if (hasValue) {
                    if (isToday) {
                      // Today's bar: slightly brighter
                      barColor = ProfileColors.accent;
                    } else {
                      // Other active days: full accent
                      barColor = ProfileColors.accent.withValues(alpha: 0.85);
                    }
                  } else {
                    // Inactive days: 40% opacity placeholder
                    barColor =
                        ProfileColors.surfaceLight.withValues(alpha: 0.4);
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        height: hasValue ? height.clamp(24.0, 80.0) : 8.0,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Weekday labels
        Row(
          children: List.generate(7, (index) {
            final day = days[index];
            final value = values[index];
            final hasValue = value > 0;
            return Expanded(
              child: Center(
                child: Text(
                  _weekdays[day.date.weekday - 1],
                  style: TextStyle(
                    color: hasValue
                        ? ProfileColors.accent
                        : ProfileColors.textMuted,
                    fontSize: 10,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        // Empty bars placeholder
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: ProfileColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 6),

        // Weekday labels
        Row(
          children: List.generate(7, (index) {
            final now = DateTime.now();
            final date = now.subtract(Duration(days: 6 - index));
            final isToday = index == 6;
            return Expanded(
              child: Center(
                child: Text(
                  _weekdays[date.weekday - 1],
                  style: TextStyle(
                    color: isToday
                        ? ProfileColors.accent
                        : ProfileColors.textMuted,
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
