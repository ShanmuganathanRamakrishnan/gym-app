import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/workout_session.dart';
import 'package:gym_app/models/muscle_selector_mapping.dart';
import 'package:gym_app/services/muscle_stats_service.dart';

void main() {
  late MuscleStatsService service;

  setUp(() {
    service = MuscleStatsService();
  });

  // Helpers
  WorkoutSession createSession(DateTime date, List<WorkoutExercise> exercises) {
    return WorkoutSession(
      id: '1',
      name: 'Test Session',
      startTime: date,
      endTime: date.add(const Duration(minutes: 60)),
      exercises: exercises,
    );
  }

  WorkoutExercise createExercise(String id, String muscleGroup, int sets) {
    return WorkoutExercise(
      id: id,
      exerciseId: id,
      name: id,
      muscleGroup: muscleGroup,
      sets: List.generate(
          sets,
          (i) => WorkoutSet(
              setNumber: i + 1, weight: 100, reps: 10, completed: true)),
    );
  }

  group('Advanced Stats Services', () {
    test('computeMuscleDistribution counts participation without splitting',
        () {
      final session = createSession(DateTime(2025, 1, 1), [
        createExercise(
            'bench_press', 'Chest', 2), // Targets Chest, Shoulders, Triceps
      ]);

      final dist = service.computeMuscleDistribution(
          [session], DateTime(2025, 1, 1), DateTime(2025, 1, 1, 23, 59));

      // Bench Press (2 sets) -> Chest: 2, Shoulders: 2, Triceps: 2
      expect(dist[InternalMuscle.chest], 2);
      expect(dist[InternalMuscle.shoulders], 2);
      expect(dist[InternalMuscle.triceps], 2);
    });

    test('computeMainExercises aggregates and sorts correctly', () {
      final session = createSession(DateTime(2025, 1, 1), [
        createExercise('squat', 'Quads', 5),
        createExercise('bench', 'Chest', 3),
      ]);
      final session2 = createSession(DateTime(2025, 1, 2), [
        createExercise('bench', 'Chest', 3), // Total Bench = 6
      ]);

      final stats = service.computeMainExercises(
          [session, session2], DateTime(2025, 1, 1), DateTime(2025, 1, 7));

      expect(stats.length, 2);
      expect(stats[0].exerciseId, 'bench');
      expect(stats[0].totalSets, 6);
      expect(stats[1].exerciseId, 'squat');
      expect(stats[1].totalSets, 5);
    });

    test('computeMonthlyReport aggregates sets and duration', () {
      final s1 = createSession(DateTime(2025, 1, 10), [
        createExercise('e1', 'm1', 5),
      ]); // 60 mins (default helper), 5 sets
      final s2 = createSession(DateTime(2025, 1, 20), [
        createExercise('e2', 'm2', 5),
      ]); // 60 mins, 5 sets

      final report =
          service.computeMonthlyReport([s1, s2], DateTime(2025, 1, 1));

      expect(report.workouts, 2);
      expect(report.totalSets, 10);
      expect(report.totalDurationMinutes, 120);
    });
  });
}
