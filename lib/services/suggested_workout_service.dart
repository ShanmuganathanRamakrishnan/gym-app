import '../models/routine.dart';
import '../data/prebuilt_routines.dart';
import 'routine_store.dart';

/// Result of suggested workout calculation
class SuggestedWorkout {
  final String routineId;
  final String name;
  final String subtitle;
  final int exerciseCount;
  final List<RoutineExercise> exercises;
  final int ruleApplied; // 1, 2, 3, or 4

  const SuggestedWorkout({
    required this.routineId,
    required this.name,
    required this.subtitle,
    required this.exerciseCount,
    required this.exercises,
    required this.ruleApplied,
  });
}

/// Deterministic workout suggestion service
/// Uses priority rules to suggest the next workout
class SuggestedWorkoutService {
  static final SuggestedWorkoutService _instance =
      SuggestedWorkoutService._internal();
  factory SuggestedWorkoutService() => _instance;
  SuggestedWorkoutService._internal();

  SuggestedWorkout? _cachedSuggestion;
  DateTime? _cacheTime;

  // Cache duration - refresh on app restart or after 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Get suggested workout (cached per session)
  Future<SuggestedWorkout> getSuggestedWorkout({
    required ExperienceLevel userLevel,
    String? lastCompletedRoutineId,
    List<String>? recentRoutineIds, // Last 14 days
  }) async {
    // Check cache
    if (_cachedSuggestion != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedSuggestion!;
    }

    final routineStore = RoutineStore();
    await routineStore.init();

    final userRoutines = routineStore.routines;

    // RULE 1: Continue a split if active
    if (lastCompletedRoutineId != null && userRoutines.isNotEmpty) {
      final splitSuggestion = _getSplitProgression(
        lastCompletedRoutineId,
        userRoutines,
      );
      if (splitSuggestion != null) {
        _cachedSuggestion = splitSuggestion;
        _cacheTime = DateTime.now();
        return splitSuggestion;
      }
    }

    // RULE 2: Fallback to most used routine (last 14 days)
    if (recentRoutineIds != null && recentRoutineIds.isNotEmpty) {
      final mostUsedSuggestion = _getMostUsedRoutine(
        recentRoutineIds,
        userRoutines,
      );
      if (mostUsedSuggestion != null) {
        _cachedSuggestion = mostUsedSuggestion;
        _cacheTime = DateTime.now();
        return mostUsedSuggestion;
      }
    }

    // RULE 3: Fallback to last completed workout
    if (lastCompletedRoutineId != null) {
      final matching =
          userRoutines.where((r) => r.id == lastCompletedRoutineId);
      if (matching.isNotEmpty) {
        final lastRoutine = matching.first;
        final suggestion = _routineToSuggestion(lastRoutine, 3);
        _cachedSuggestion = suggestion;
        _cacheTime = DateTime.now();
        return suggestion;
      }
    }

    // RULE 4: Last resort - default based on experience level
    final defaultSuggestion = _getDefaultRoutine(userLevel);
    _cachedSuggestion = defaultSuggestion;
    _cacheTime = DateTime.now();
    return defaultSuggestion;
  }

  /// Clear cache (call after workout completion)
  void invalidateCache() {
    _cachedSuggestion = null;
    _cacheTime = null;
  }

  /// RULE 1: Get next workout in split progression
  SuggestedWorkout? _getSplitProgression(
    String lastRoutineId,
    List<Routine> userRoutines,
  ) {
    // Find the last completed routine
    final lastRoutineIndex =
        userRoutines.indexWhere((r) => r.id == lastRoutineId);
    if (lastRoutineIndex == -1) return null;

    // Check if user has multiple routines (indicating a split)
    if (userRoutines.length < 2) return null;

    // Simple round-robin: suggest the next routine in the list
    final nextIndex = (lastRoutineIndex + 1) % userRoutines.length;
    final nextRoutine = userRoutines[nextIndex];

    return _routineToSuggestion(nextRoutine, 1);
  }

  /// RULE 2: Get most frequently used routine
  SuggestedWorkout? _getMostUsedRoutine(
    List<String> recentRoutineIds,
    List<Routine> userRoutines,
  ) {
    if (recentRoutineIds.isEmpty || userRoutines.isEmpty) return null;

    // Count frequency
    final frequency = <String, int>{};
    for (final id in recentRoutineIds) {
      frequency[id] = (frequency[id] ?? 0) + 1;
    }

    // Find most used that still exists
    String? mostUsedId;
    int maxCount = 0;
    for (final entry in frequency.entries) {
      if (entry.value > maxCount &&
          userRoutines.any((r) => r.id == entry.key)) {
        mostUsedId = entry.key;
        maxCount = entry.value;
      }
    }

    if (mostUsedId == null) return null;

    final routine = userRoutines.firstWhere((r) => r.id == mostUsedId);
    return _routineToSuggestion(routine, 2);
  }

  /// RULE 4: Get default routine based on experience level
  SuggestedWorkout _getDefaultRoutine(ExperienceLevel level) {
    PrebuiltRoutine prebuilt;

    switch (level) {
      case ExperienceLevel.beginner:
        prebuilt = prebuiltRoutines.firstWhere(
          (r) => r.id == 'beginner_full_body',
          orElse: () => prebuiltRoutines.first,
        );
        break;
      case ExperienceLevel.intermediate:
        prebuilt = prebuiltRoutines.firstWhere(
          (r) => r.id == 'intermediate_upper_lower',
          orElse: () => prebuiltRoutines.first,
        );
        break;
      case ExperienceLevel.advanced:
        prebuilt = prebuiltRoutines.firstWhere(
          (r) => r.id == 'advanced_ppl',
          orElse: () => prebuiltRoutines.first,
        );
        break;
    }

    return SuggestedWorkout(
      routineId: prebuilt.id,
      name: prebuilt.name,
      subtitle: prebuilt.focusAreas.take(3).join(' · '),
      exerciseCount: prebuilt.exercises.length,
      exercises: prebuilt.exercises,
      ruleApplied: 4,
    );
  }

  /// Convert a user routine to SuggestedWorkout
  SuggestedWorkout _routineToSuggestion(Routine routine, int rule) {
    return SuggestedWorkout(
      routineId: routine.id,
      name: routine.name,
      subtitle: routine.targetFocus.take(3).join(' · '),
      exerciseCount: routine.exercises.length,
      exercises: routine.exercises,
      ruleApplied: rule,
    );
  }
}
