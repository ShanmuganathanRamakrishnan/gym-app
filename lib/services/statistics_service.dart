import '../models/workout_session.dart';
import '../data/exercise_info.dart';

enum TimeWindow {
  thisWeek,
  lastWeek,
  last4Weeks,
}

enum BarMetric {
  volume,
  reps,
  duration,
  sets, // Default for Hevy-like
}

class MuscleStats {
  final Map<String, double> setsPerMuscle;
  final int totalSets;

  MuscleStats(this.setsPerMuscle, this.totalSets);
}

class WeeklyBarData {
  final String dayLabel; // M, T, W...
  final double value;
  final DateTime date;

  WeeklyBarData(this.dayLabel, this.value, this.date);
}

class StatisticsService {
  // Singleton pattern optional, but keeping it simple for now
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  /// Filter sessions based on time window
  List<WorkoutSession> filterSessions(
      List<WorkoutSession> sessions, TimeWindow window) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (window) {
      case TimeWindow.thisWeek:
        // Start of current week (Monday)
        // ISO 8601: Mon=1, Sun=7
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day); // Truncate time
        break;
      case TimeWindow.lastWeek:
        final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfLastWeek =
            startOfThisWeek.subtract(const Duration(days: 7));
        start = DateTime(
            startOfLastWeek.year, startOfLastWeek.month, startOfLastWeek.day);

        final endOfLastWeek =
            startOfThisWeek.subtract(const Duration(seconds: 1));
        end = endOfLastWeek;
        break;
      case TimeWindow.last4Weeks:
        // Rolling 28 days
        start = now.subtract(const Duration(days: 28));
        start = DateTime(start.year, start.month, start.day);
        break;
    }

    return sessions.where((s) {
      if (s.endTime == null) return false;
      return s.endTime!.isAfter(start) &&
          s.endTime!.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Aggregate sets per muscle group
  MuscleStats aggregateMuscleSets(List<WorkoutSession> sessions) {
    final Map<String, double> distribution = {};
    int grandTotalSets = 0;

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        // Count valid sets
        // Definition: completed=true OR reps > 0 OR weight > 0 (bodyweight allowed)
        // Per "data_rules": if set.completed == true OR set.reps > 0 OR set.weight > 0
        final validSetsCount = exercise.sets
            .where((s) => s.completed || s.reps > 0 || s.weight > 0)
            .length;

        if (validSetsCount == 0) continue;

        grandTotalSets += validSetsCount;

        // Determine muscle groups
        // Use metadata from ExerciseInfo if possible, fallback to exercise.muscleGroup
        String primaryMuscle = exercise.muscleGroup;

        // Lookup more robust metadata if id match (optional, but good for standardization)
        // Check if we can normalize using the database
        if (exerciseInfoDatabase.containsKey(exercise.exerciseId)) {
          primaryMuscle =
              exerciseInfoDatabase[exercise.exerciseId]!.primaryMuscle;
        }

        // Split multiple muscles (e.g. "Quads / Glutes")
        final muscles = primaryMuscle
            .split(RegExp(r'[/&,]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if (muscles.isEmpty) {
          distribution['Other'] = (distribution['Other'] ?? 0) + validSetsCount;
        } else {
          final countPerMuscle = validSetsCount / muscles.length;
          for (final m in muscles) {
            final normalized = _normalizeMuscleName(m);
            distribution[normalized] =
                (distribution[normalized] ?? 0) + countPerMuscle;
          }
        }
      }
    }

    return MuscleStats(distribution, grandTotalSets);
  }

  /// Aggregate weekly bar data (Volume, Reps, Duration, or Sets)
  /// For "This Week": partial data. For "Last Week": full 7 days.
  List<WeeklyBarData> aggregateWeeklyBars(
      List<WorkoutSession> sessions, TimeWindow window, BarMetric metric) {
    // Generate empty buckets for the days in the window
    final Map<int, double> dailyTotals = {}; // Key: day index relative to start
    final List<WeeklyBarData> bars = [];

    // Determine loop range
    // Logic similar to filterSessions but we need the discrete days
    final now = DateTime.now();
    DateTime start;
    int dayCount;

    if (window == TimeWindow.thisWeek) {
      start = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(start.year, start.month, start.day);
      dayCount = 7;
    } else if (window == TimeWindow.lastWeek) {
      final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
      start = startOfThisWeek.subtract(const Duration(days: 7));
      start = DateTime(start.year, start.month, start.day);
      dayCount = 7;
    } else {
      // Last 4 weeks is not shown as daily bars usually (too cramped)?
      // Hevy shows "Last 3 months" as weekly bars.
      // Requirement: "weekly_bars_block: small weekday bars (S M T W T F S)"
      // This implies it ALWAYS shows a single week view?
      // If "Last 4 Weeks" is selected, the Heatmap/Distribution update, but what about the bars?
      // Usually the bars reflect the breakdown of the selected period.
      // If 28 days selected, 28 bars?
      // "small weekday bars (S M T W T F S)" implies 7 bars.
      // Let's assume for "Last 4 Weeks", it might aggregate by Week? Or show last 7 days?
      // The prompt says "Week: S M T W T F S". That is 7 bars.
      // If period is "Last 4 Weeks", showing 7 bars is confusing unless it's "Last 7 days of the window"?
      // OR maybe the Weekly Bars block is independent?
      // Prompt "weekly_bars_block... S M T W T F S".
      // I will assume it shows the "Selected Week" if Week mode.
      // If "Last 4 Weeks" mode, maybe show 4 bars (one per week)?
      // "Weekly bars" -> implies Metric per Day of Week.
      // I'll stick to 7 days logic for This/Last week.
      // For "Last 4 Weeks", I will bail to "Average per week" or just show last 7 days?
      // For safety, I'll return 7 days associated with "This Week" or "Last Week".
      // If "Last 4 Weeks" is passed, I'll aggregate by WEEK (4 bars) or just return 28 days?
      // Let's assume 7 days for now to match the UI description.

      // actually, the prompt says "Last 7 days body graph" in the screenshot title.
      // So likely this block is ALWAYS "Last 7 days"?
      // "UX/UI SPEC ... weekly_bars_block ... small weekday bars".
      // I'll make it dependent on the window if it fits 7 days.
      // If Last 4 Weeks (28 days), I can return 28 points, UI decides how to render.
      // But naming is "aggregateWeeklyBars".

      // Let's handle 7 days logic strictly for ThisWeek/LastWeek.
      start = now.subtract(const Duration(days: 28)); // Fallback
      dayCount = 28;
    }

    // Initialize buckets
    for (int i = 0; i < dayCount; i++) {
      dailyTotals[i] = 0.0;
    }

    for (final session in sessions) {
      if (session.endTime == null) continue;

      // Calculate day index
      final dayDiff = session.endTime!.difference(start).inDays;
      if (dayDiff >= 0 && dayDiff < dayCount) {
        double value = 0;
        switch (metric) {
          case BarMetric.sets:
            // Total sets
            value = session.totalSetsCompleted.toDouble();
            break;
          case BarMetric.duration:
            value = session.totalDuration.inMinutes.toDouble();
            break;
          case BarMetric.volume:
            // Sum reps * weight
            value = session.exercises.fold(0.0, (sum, ex) {
              return sum +
                  ex.sets.where((s) => s.completed).fold(0.0, (sSum, set) {
                    final weight = set.weight > 0
                        ? set.weight
                        : 1.0; // Bodyweight = 1 for volume calc placeholder
                    return sSum + (set.reps * weight);
                  });
            });
            break;
          case BarMetric.reps:
            value = session.exercises.fold(0.0, (sum, ex) {
              return sum +
                  ex.sets
                      .where((s) => s.completed)
                      .fold(0.0, (sSum, set) => sSum + set.reps);
            });
            break;
        }
        dailyTotals[dayDiff] = (dailyTotals[dayDiff] ?? 0) + value;
      }
    }

    // Convert to list
    for (int i = 0; i < dayCount; i++) {
      final date = start.add(Duration(days: i));
      // Label logic: M, T, W...
      String label = _getDayLabel(date.weekday);
      bars.add(WeeklyBarData(label, dailyTotals[i]!, date));
    }

    return bars;
  }

  String _getDayLabel(int weekday) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[weekday - 1]; // weekday is 1-7
  }

  String _normalizeMuscleName(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('chest') || lower.contains('pec')) {
      return 'Chest';
    }
    if (lower.contains('back') ||
        lower.contains('lat') ||
        lower.contains('row') ||
        lower.contains('posterior')) {
      return 'Back';
    }
    if (lower.contains('quad') ||
        lower.contains('squat') ||
        lower.contains('leg press')) {
      return 'Quads';
    }
    if (lower.contains('ham') ||
        lower.contains('deadlift') ||
        lower.contains('leg curl')) {
      return 'Hamstrings';
    }
    if (lower.contains('glute') || lower.contains('hip')) {
      return 'Glutes';
    }
    if (lower.contains('calf') || lower.contains('calves')) {
      return 'Calves';
    }
    if (lower.contains('bicep') || lower.contains('curl')) {
      return 'Biceps';
    }
    if (lower.contains('tricep') ||
        lower.contains('extension') ||
        lower.contains('pushdown')) {
      return 'Triceps';
    }
    if (lower.contains('shoulder') ||
        lower.contains('delt') ||
        lower.contains('press')) {
      return 'Shoulders';
    }
    if (lower.contains('core') ||
        lower.contains('abs') ||
        lower.contains('plank') ||
        lower.contains('crunch')) {
      return 'Core';
    }
    return 'Other';
  }
}
