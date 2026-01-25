import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/services/statistics_service.dart';
import 'package:gym_app/models/workout_session.dart';

void main() {
  group('StatisticsService', () {
    final service = StatisticsService();

    test('aggregateMuscleSets splits multi-muscle group evenly', () {
      final session = WorkoutSession(
        id: '1',
        name: 'Test',
        startTime: DateTime.now(),
        exercises: [
          WorkoutExercise(
            id: 'e1',
            exerciseId: 'custom_1',
            name: 'Pushdown',
            muscleGroup: 'Chest / Triceps', // Should split
            sets: [
              WorkoutSet(setNumber: 1, reps: 10, weight: 10, completed: true),
              WorkoutSet(setNumber: 2, reps: 10, weight: 10, completed: true),
            ],
          ),
        ],
      );

      final stats = service.aggregateMuscleSets([session]);

      // Total sets = 2
      expect(stats.totalSets, 2);

      // Chest = 1 (2 sets * 0.5)
      // Triceps = 1 (2 sets * 0.5)
      expect(stats.setsPerMuscle['Chest'], 1.0);
      expect(stats.setsPerMuscle['Triceps'], 1.0);
    });

    test('counts bodyweight exercise as valid set', () {
      final session = WorkoutSession(
        id: '1',
        name: 'Test',
        startTime: DateTime.now(),
        exercises: [
          WorkoutExercise(
            id: 'e1',
            exerciseId: 'custom_2',
            name: 'Push Ups',
            muscleGroup: 'Chest',
            sets: [
              WorkoutSet(setNumber: 1, reps: 10, weight: 0, completed: true),
            ],
          ),
        ],
      );

      final stats = service.aggregateMuscleSets([session]);
      expect(stats.totalSets, 1);
      expect(stats.setsPerMuscle['Chest'], 1.0);
    });
  });
}
