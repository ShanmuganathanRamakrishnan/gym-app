import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/services/muscle_stats_service.dart';
import 'package:gym_app/models/workout_session.dart';
import 'package:gym_app/models/muscle_svg_map.dart'; // Canonical Map

void main() {
  late MuscleStatsService service;

  setUp(() {
    service = MuscleStatsService();
  });

  // Helper to create a dummy session
  WorkoutSession createSession(String exerciseId, {int sets = 1}) {
    return WorkoutSession(
      id: 'test_session',
      name: 'Test Session',
      startTime: DateTime.now(), // required
      endTime: DateTime.now().add(const Duration(minutes: 60)),
      exercises: [
        WorkoutExercise(
          id: 'ex_1',
          exerciseId: exerciseId,
          name: exerciseId, // name same as id for simplicity
          muscleGroup: 'Other', // fallback
          sets: List.generate(
              sets,
              (i) => WorkoutSet(
                    setNumber: i + 1,
                    weight: 100,
                    reps: 10,
                    completed: true,
                  )),
        ),
      ],
    );
  }

  test('Romanian Deadlift maps to Hamstrings, Glutes, Back', () {
    final session = createSession('romanian_deadlift', sets: 10);
    final load = service.computeMuscleLoad([session]);

    expect(load[InternalMuscle.hamstrings], equals(10.0));
    expect(load[InternalMuscle.glutes], equals(10.0));
    expect(load[InternalMuscle.back], equals(10.0));
    expect(load[InternalMuscle.chest], isNull);
  });

  test('Generic "Legs" fallback maps to Hamstrings', () {
    // Session with unknown ID but muscleGroup "Legs"
    final session = WorkoutSession(
      id: 'test_session_2',
      name: 'Leg Day',
      startTime: DateTime.now(),
      exercises: [
        WorkoutExercise(
          id: 'ex_2',
          exerciseId: 'unknown_leg_press_machine',
          name: 'Some Leg Machine',
          muscleGroup: 'Legs', // "Legs"
          sets: [
            WorkoutSet(setNumber: 1, completed: true, weight: 10, reps: 10)
          ],
        ),
      ],
    );

    final load = service.computeMuscleLoad([session]);
    // Logic for "Legs": Quads, Hamstrings, Glutes, Calves
    expect(load[InternalMuscle.hamstrings], equals(1.0));
    expect(load[InternalMuscle.quads], equals(1.0));
  });

  test('Conventional Deadlift maps to Hamstrings', () {
    final session = createSession('deadlift');
    final load = service.computeMuscleLoad([session]);

    expect(load[InternalMuscle.hamstrings], equals(1.0));
    expect(load[InternalMuscle.back], equals(1.0));
  });
}
