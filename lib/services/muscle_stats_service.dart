import '../models/workout_session.dart';
import '../models/muscle_selector_mapping.dart';
import '../data/exercise_info.dart';

class MuscleStatsService {
  /// Compute raw set count (load) per muscle from a list of sessions.
  Map<InternalMuscle, double> computeMuscleLoad(List<WorkoutSession> sessions) {
    final Map<InternalMuscle, double> muscleLoad = {};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        // Get target muscles
        final targets =
            _getTargetMuscles(exercise.exerciseId, exercise.muscleGroup);

        // Compute "intensity" for this exercise
        // For now, simple set count weighting.
        final validSets = exercise.sets.where((s) => s.completed).length;
        if (validSets == 0) continue;

        // Distribute load
        final loadPerMuscle =
            validSets.toDouble(); // Simple count per muscle (shared)

        for (final muscle in targets) {
          _distributeLoad(muscle, loadPerMuscle, muscleLoad);
        }
      }
    }

    return muscleLoad;
  }

  /// Distributes load to target muscle, preserving identity.
  void _distributeLoad(
      InternalMuscle muscle, double load, Map<InternalMuscle, double> map) {
    if (muscle == InternalMuscle.other) return;

    // Previous Aggregation (Reverted):
    // We now treat Forearms, Adductors, Abductors as First-Class citizens.
    // They will map to their own keys in the heatmap.

    _addToMap(muscle, load, map);
  }

  void _addToMap(
      InternalMuscle key, double value, Map<InternalMuscle, double> map) {
    map[key] = (map[key] ?? 0) + value;
  }

  /// Resolve muscles for a given exercise.
  List<InternalMuscle> _getTargetMuscles(
      String exerciseId, String fallbackMuscleStr) {
    // 1. Specific Compound overrides (The "Big 3" and common compounds)
    switch (exerciseId) {
      case 'bench_press':
      case 'incline_db_press':
      case 'push_up':
      case 'dips':
        return [
          InternalMuscle.chest,
          InternalMuscle.shoulders,
          InternalMuscle.triceps
        ];

      case 'deadlift':
      case 'rack_pull':
        return [
          InternalMuscle.back,
          InternalMuscle.glutes,
          InternalMuscle.hamstrings
        ];

      case 'squat':
      case 'leg_press':
      case 'lunges':
        return [InternalMuscle.quads, InternalMuscle.glutes];

      case 'overhead_press':
      case 'shoulder_press':
      case 'military_press':
        return [InternalMuscle.shoulders, InternalMuscle.triceps];

      case 'pull_up':
      case 'chin_up':
      case 'lat_pulldown':
      case 'barbell_row':
        return [InternalMuscle.back, InternalMuscle.biceps];
    }

    // 2. Fallback: Parse the primaryMuscle string
    String muscleStr = fallbackMuscleStr;
    if (exerciseInfoDatabase.containsKey(exerciseId)) {
      muscleStr = exerciseInfoDatabase[exerciseId]!.primaryMuscle;
    }

    // Handle string-based fallbacks (e.g. adductors) BEFORE parsing to enum
    final lower = muscleStr.toLowerCase();

    // Explicit Fallback Logic for strings that might parse to 'other'
    // But now we have enums for them, so we let parseInternalMuscle handle it.
    // Except for generic "Arms" or "Legs" which still need distribution.

    // Fix for "Arms" generic
    if (lower == 'arms') {
      return [InternalMuscle.biceps, InternalMuscle.triceps];
    }

    // Fix for "Legs" generic
    if (lower == 'legs') {
      return [
        InternalMuscle.quads,
        InternalMuscle.hamstrings,
        InternalMuscle.glutes,
        InternalMuscle.calves
      ];
    }

    // "Core" usually maps to Abs
    if (lower == 'core') {
      return [InternalMuscle.abs];
    }

    final parts = muscleStr.split(RegExp(r'[/,&]'));
    final Set<InternalMuscle> found = {};

    for (final part in parts) {
      final parsed = parseInternalMuscle(part.trim());
      if (parsed != null && parsed != InternalMuscle.other) {
        found.add(parsed);
      }
    }

    if (found.isNotEmpty) return found.toList();

    return [InternalMuscle.other];
  }

  /// Get top exercises contributing to a specific muscle group.
  /// Returns List of MapEntry(Exercise Name, Set Count)
  List<MapEntry<String, int>> getTopExercises(
      InternalMuscle muscle, List<WorkoutSession> sessions) {
    final Map<String, int> exerciseCounts = {};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        // Check if this exercise hits the target muscle
        final targets =
            _getTargetMuscles(exercise.exerciseId, exercise.muscleGroup);

        // We consider it a hit if:
        // 1. It is explicitly in the target lists
        // 2. OR if it was a mapped fallback.
        // Logic: if muscle is Biceps, and exercise was Forearms, we mapped Forearms -> Biceps.
        // So we should check if _distributeLoad WOULD have sent it here.
        // But _distributeLoad is one-way.
        // Simplified check: If the direct target contains muscle, count it.
        // What if user taps "Biceps" and wants to see "Forearm Curls"?
        // Forearm Curls -> targets=[Forearms].
        // Forearms -> Biceps/Triceps in distribution.
        // So checking `targets.contains(muscle)` will fail if muscle is Biceps and target is Forearms.

        // BETTER: Use _distributeLoad logic in reverse or simply check if this exercise contributes?
        // Let's simlulate distribution for this exercise.
        bool contributes = false;
        for (final t in targets) {
          if (t == muscle) {
            contributes = true;
            break;
          }
          // Check mapping
          if (t == InternalMuscle.forearms &&
              (muscle == InternalMuscle.biceps ||
                  muscle == InternalMuscle.triceps)) {
            contributes = true;
            break;
          }
        }

        if (contributes) {
          // Count completed valid sets
          final count = exercise.sets
              .where((s) => s.completed) // Simplified count
              .length;
          if (count > 0) {
            exerciseCounts[exercise.name] =
                (exerciseCounts[exercise.name] ?? 0) + count;
          }
        }
      }
    }

    // Sort descending
    final sorted = exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted;
  }

  // --- Advanced Stats (Phase 11) ---

  /// Computes the distribution of sets per muscle group.
  /// Counts 1 full set for each muscle targeted by an exercise (no splitting).
  ///
  /// [start] and [end] are inclusive.
  Map<InternalMuscle, int> computeMuscleDistribution(
      List<WorkoutSession> sessions, DateTime start, DateTime end) {
    final Map<InternalMuscle, int> distribution = {};

    // Filter sessions by range
    final filtered = sessions.where((s) {
      if (s.endTime == null) return false;
      return s.endTime!.isAfter(start.subtract(const Duration(seconds: 1))) &&
          s.endTime!.isBefore(end.add(const Duration(seconds: 1)));
    });

    for (final session in filtered) {
      for (final exercise in session.exercises) {
        final validSets = exercise.sets.where((s) {
          // Completed sets. For bodyweight (weight=0), ensure reps > 0.
          return s.completed && (s.weight > 0 || s.reps > 0);
        }).length;

        if (validSets == 0) continue;

        // Get targets
        final targets =
            _getTargetMuscles(exercise.exerciseId, exercise.muscleGroup);

        // Increment for EACH target (No splitting)
        for (final muscle in targets) {
          if (muscle == InternalMuscle.other) continue;
          distribution[muscle] = (distribution[muscle] ?? 0) + validSets;
        }
      }
    }

    return distribution;
  }

  /// Computes top exercises by set volume.
  /// Returns top 5.
  List<ExerciseStat> computeMainExercises(
      List<WorkoutSession> sessions, DateTime start, DateTime end) {
    final Map<String, int> aggMap = {}; // ID -> Sets

    // Filter sessions
    final filtered = sessions.where((s) {
      if (s.endTime == null) return false;
      return s.endTime!.isAfter(start.subtract(const Duration(seconds: 1))) &&
          s.endTime!.isBefore(end.add(const Duration(seconds: 1)));
    });

    for (final session in filtered) {
      for (final exercise in session.exercises) {
        final validSets = exercise.sets.where((s) => s.completed).length;
        if (validSets == 0) continue;

        // Use exerciseId for aggregation, but we need a display name.
        aggMap[exercise.exerciseId] =
            (aggMap[exercise.exerciseId] ?? 0) + validSets;
      }
    }

    // Convert to list and sort
    final List<ExerciseStat> stats = [];

    // We need names. Let's do a quick lookup pass
    final Map<String, String> names = {};
    for (final s in filtered) {
      for (final e in s.exercises) {
        names[e.exerciseId] = e.name;
      }
    }

    aggMap.forEach((id, count) {
      stats.add(ExerciseStat(
        exerciseId: id,
        name: names[id] ?? id,
        totalSets: count,
      ));
    });

    stats.sort((a, b) => b.totalSets.compareTo(a.totalSets));

    return stats.take(5).toList();
  }

  /// Generates a monthly summary report.
  MonthlyStats computeMonthlyReport(
      List<WorkoutSession> sessions, DateTime referenceDate) {
    // Determine start/end of month
    final start = DateTime(referenceDate.year, referenceDate.month, 1);
    final nextMonth = DateTime(referenceDate.year, referenceDate.month + 1, 1);
    final end = nextMonth.subtract(const Duration(seconds: 1));

    final filtered = sessions.where((s) {
      if (s.endTime == null) return false;
      return s.endTime!.isAfter(start.subtract(const Duration(seconds: 1))) &&
          s.endTime!.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    int totalSets = 0;
    int totalDuration = 0;

    for (final s in filtered) {
      totalSets += s.totalSetsCompleted;
      totalDuration += s.totalDuration.inMinutes;
    }

    return MonthlyStats(
      workouts: filtered.length,
      totalSets: totalSets,
      totalDurationMinutes: totalDuration,
      month: start,
    );
  }
}

class ExerciseStat {
  final String exerciseId;
  final String name;
  final int totalSets;

  ExerciseStat({
    required this.exerciseId,
    required this.name,
    required this.totalSets,
  });
}

class MonthlyStats {
  final int workouts;
  final int totalSets;
  final int totalDurationMinutes;
  final DateTime month;

  MonthlyStats({
    required this.workouts,
    required this.totalSets,
    required this.totalDurationMinutes,
    required this.month,
  });
}
