import '../models/workout_session.dart';
import '../models/muscle_selector_mapping.dart';
import '../data/exercise_info.dart';

class MuscleStatsService {
  /// Compute raw set count (load) per muscle from a list of sessions.
  ///
  /// Rules:
  /// - Only completed sets with (reps > 0 OR weight > 0) count.
  /// - Compound exercises distribute the set count evenly across target muscles.
  ///   (e.g. 1 set of Bench Press (3 muscles) = 0.33 sets for Chest, Shoulders, Triceps)
  Map<InternalMuscle, double> computeMuscleLoad(List<WorkoutSession> sessions) {
    final Map<InternalMuscle, double> load = {};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        // 1. Count valid sets
        final validSets = exercise.sets.where((s) {
          // Must be completed AND have some work done (reps or weight)
          return s.completed && (s.reps > 0 || s.weight > 0);
        }).length;

        if (validSets == 0) continue;

        // 2. Identify target muscles
        // Use ID for specific compound logic, fallback to primaryMuscle string
        final targets =
            _getTargetMuscles(exercise.exerciseId, exercise.muscleGroup);

        if (targets.isEmpty) {
          // Map to 'other' if no targets found
          load[InternalMuscle.other] =
              (load[InternalMuscle.other] ?? 0) + validSets;
          continue;
        }

        // 3. Distribute load
        // "Compound exercises must distribute sets evenly"
        final setsPerMuscle = validSets.toDouble() / targets.length;

        for (final muscle in targets) {
          load[muscle] = (load[muscle] ?? 0) + setsPerMuscle;
        }
      }
    }

    return load;
  }

  /// Resolve muscles for a given exercise.
  /// Applies specific logic for big compounds, falls back to parsing the muscle string.
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
    // e.g. "Quads / Glutes" or "Back" or "Chest"
    // Use the exerciseInfoDatabase if valid ID, else use the string on the object
    String muscleStr = fallbackMuscleStr;
    if (exerciseInfoDatabase.containsKey(exerciseId)) {
      muscleStr = exerciseInfoDatabase[exerciseId]!.primaryMuscle;
    }

    final parts = muscleStr.split(RegExp(r'[/,&]'));
    final Set<InternalMuscle> found = {};

    for (final part in parts) {
      final parsed = parseInternalMuscle(part.trim());
      if (parsed != null && parsed != InternalMuscle.other) {
        found.add(parsed);
      }
    }

    // If fallback parsing failed to find specifics but we returned 'other',
    // maybe try to map 'other' if the string was basically empty?
    // parseInternalMuscle returns 'other' for everything else.
    // If we found valid muscles, return them.
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
        if (targets.contains(muscle)) {
          // Count completed valid sets
          final count = exercise.sets
              .where((s) => s.completed && (s.reps > 0 || s.weight > 0))
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
}
