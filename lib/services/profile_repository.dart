import 'package:flutter/foundation.dart';
import 'workout_history_service.dart';

/// Profile aggregates computed from workout history
class ProfileAggregates {
  final ProfileStats stats;
  final StreakInfo streaks;
  final TrainingFocus? trainingFocus;
  final List<WorkoutHistoryEntry> recentWorkouts;

  const ProfileAggregates({
    required this.stats,
    required this.streaks,
    this.trainingFocus,
    required this.recentWorkouts,
  });

  factory ProfileAggregates.empty() => ProfileAggregates(
        stats: ProfileStats.empty(),
        streaks: StreakInfo.empty(),
        trainingFocus: null,
        recentWorkouts: const [],
      );
}

/// Summary statistics for profile
class ProfileStats {
  final int totalWorkouts;
  final int totalExercises;
  final int totalSets;
  final int totalMinutes;

  const ProfileStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.totalSets,
    required this.totalMinutes,
  });

  factory ProfileStats.empty() => const ProfileStats(
        totalWorkouts: 0,
        totalExercises: 0,
        totalSets: 0,
        totalMinutes: 0,
      );
}

/// Streak information
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
  });

  factory StreakInfo.empty() => const StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        lastWorkoutDate: null,
      );
}

/// Training focus derived from workout history
class TrainingFocus {
  final String primaryMuscle;
  final double percentage;
  final Map<String, int> muscleDistribution;

  const TrainingFocus({
    required this.primaryMuscle,
    required this.percentage,
    required this.muscleDistribution,
  });
}

/// Repository for profile data aggregation
class ProfileRepository {
  final WorkoutHistoryService _historyService;

  ProfileRepository({WorkoutHistoryService? historyService})
      : _historyService = historyService ?? WorkoutHistoryService();

  /// Get profile aggregates from local workout history
  Future<ProfileAggregates> getProfileAggregates() async {
    await _historyService.init();
    final history = _historyService.history;

    if (history.isEmpty) {
      return ProfileAggregates.empty();
    }

    // Compute stats
    final stats = _computeStats(history);

    // Compute streaks
    final streaks = _computeStreaks(history);

    // Compute training focus (placeholder - needs muscle group data)
    final trainingFocus = _computeTrainingFocus(history);

    // Get recent workouts
    final recentWorkouts = _historyService.getRecentWorkouts(limit: 10);

    return ProfileAggregates(
      stats: stats,
      streaks: streaks,
      trainingFocus: trainingFocus,
      recentWorkouts: recentWorkouts,
    );
  }

  ProfileStats _computeStats(List<WorkoutHistoryEntry> history) {
    int totalWorkouts = history.length;
    int totalExercises = 0;
    int totalSets = 0;
    int totalMinutes = 0;

    for (final entry in history) {
      totalExercises += entry.exerciseCount;
      totalSets += entry.totalSets;
      totalMinutes += entry.duration.inMinutes;
    }

    return ProfileStats(
      totalWorkouts: totalWorkouts,
      totalExercises: totalExercises,
      totalSets: totalSets,
      totalMinutes: totalMinutes,
    );
  }

  StreakInfo _computeStreaks(List<WorkoutHistoryEntry> history) {
    if (history.isEmpty) return StreakInfo.empty();

    // Sort by date (newest first)
    final sorted = List<WorkoutHistoryEntry>.from(history)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final lastWorkoutDate = sorted.first.completedAt;

    // Get unique workout days
    final uniqueDays = <String>{};
    for (final entry in sorted) {
      final dayKey =
          '${entry.completedAt.year}-${entry.completedAt.month}-${entry.completedAt.day}';
      uniqueDays.add(dayKey);
    }

    final sortedDays = uniqueDays.toList()..sort((a, b) => b.compareTo(a));

    // Calculate current streak
    int currentStreak = 0;
    DateTime checkDate = DateTime.now();

    for (final dayKey in sortedDays) {
      final parts = dayKey.split('-');
      final workoutDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      final daysDiff = checkDate.difference(workoutDate).inDays;

      if (daysDiff <= 1) {
        currentStreak++;
        checkDate = workoutDate;
      } else {
        break;
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? prevDate;

    for (final dayKey in sortedDays.reversed) {
      final parts = dayKey.split('-');
      final workoutDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final daysDiff = workoutDate.difference(prevDate).inDays;
        if (daysDiff == 1) {
          tempStreak++;
        } else {
          longestStreak =
              tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
        }
      }
      prevDate = workoutDate;
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastWorkoutDate: lastWorkoutDate,
    );
  }

  TrainingFocus? _computeTrainingFocus(List<WorkoutHistoryEntry> history) {
    // TODO: This requires exercise-level data with muscle groups
    // For now, return placeholder if enough workouts
    if (history.length < 3) return null;

    // Placeholder - would need to aggregate muscle groups from exercises
    return const TrainingFocus(
      primaryMuscle: 'Chest',
      percentage: 35.0,
      muscleDistribution: {
        'Chest': 35,
        'Back': 25,
        'Legs': 20,
        'Shoulders': 10,
        'Arms': 10,
      },
    );
  }

  /// Get total workout count
  int getTotalWorkouts() {
    return _historyService.history.length;
  }

  /// Check if user has enough data for training focus
  bool hasEnoughDataForFocus() {
    return _historyService.history.length >= 3;
  }
}
