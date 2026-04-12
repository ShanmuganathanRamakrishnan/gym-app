import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/routine.dart';
import 'package:gym_app/services/suggested_workout_service.dart';
import 'package:gym_app/data/prebuilt_routines.dart';

void main() {
  group('SuggestedWorkoutService Logic', () {
    late SuggestedWorkoutService service;
    late List<Routine> mockRoutines;

    setUp(() {
      service = SuggestedWorkoutService();
      // Create mock routines
      mockRoutines = [
        Routine(
          id: 'push_id',
          name: 'Push Day',
          targetFocus: ['Chest', 'Triceps'],
          exercises: [],
        ),
        Routine(
          id: 'pull_id',
          name: 'Pull Day',
          targetFocus: ['Back', 'Biceps'],
          exercises: [],
        ),
        Routine(
          id: 'legs_id',
          name: 'Leg Day',
          targetFocus: ['Legs'],
          exercises: [],
        ),
      ];
    });

    test('RULE 1: Split Progression - returns next routine', () {
      final suggestion = service.determineSuggestedWorkout(
        userLevel: ExperienceLevel.intermediate,
        userRoutines: mockRoutines,
        lastCompletedRoutineId: 'push_id',
      );

      expect(suggestion.routineId, 'pull_id');
      expect(suggestion.ruleApplied, 1);
    });

    test('RULE 1: Split Progression - wraps around list (Round Robin)', () {
      final suggestion = service.determineSuggestedWorkout(
        userLevel: ExperienceLevel.intermediate,
        userRoutines: mockRoutines,
        lastCompletedRoutineId: 'legs_id',
      );

      expect(suggestion.routineId, 'push_id');
      expect(suggestion.ruleApplied, 1);
    });

    test('RULE 2: Fallback to Most Used - returns basic fallback', () {
      final suggestion = service.determineSuggestedWorkout(
        userLevel: ExperienceLevel.intermediate,
        userRoutines: mockRoutines,
        // lastCompletedRoutineId missing/invalid for split?
        // Actually if lastCompletedRoutineId is null, Rule 1 skipped.
        lastCompletedRoutineId: null,
        recentRoutineIds: ['push_id', 'push_id', 'pull_id'],
      );

      expect(suggestion.routineId, 'push_id'); // Most occurring
      expect(suggestion.ruleApplied, 2);
    });

    test('RULE 4: Default fallback - returns prebuilt based on level', () {
      final suggestion = service.determineSuggestedWorkout(
        userLevel: ExperienceLevel.beginner,
        userRoutines: [], // No user routines
        lastCompletedRoutineId: null,
        recentRoutineIds: [],
      );

      expect(suggestion.ruleApplied, 4);
      // Beginner default is usually Full Body
      expect(suggestion.name, contains('Full Body'));
    });

    test('Split Progression Fails (Routine Deleted) -> Fallback', () {
      // 'deleted_id' is NOT in mockRoutines
      final suggestion = service.determineSuggestedWorkout(
        userLevel: ExperienceLevel.intermediate,
        userRoutines: mockRoutines,
        lastCompletedRoutineId: 'deleted_id',
        recentRoutineIds: ['pull_id', 'pull_id'],
      );

      // Rule 1 fails (can't find last routine index)
      // Should fall to Rule 2 (Most Used)
      expect(suggestion.routineId, 'pull_id');
      expect(suggestion.ruleApplied, 2);
    });
  });
}
