import '../models/routine.dart';

/// Experience levels for filtering
enum ExperienceLevel {
  beginner,
  intermediate,
  advanced,
}

/// Extension for display text
extension ExperienceLevelExt on ExperienceLevel {
  String get displayName {
    switch (this) {
      case ExperienceLevel.beginner:
        return 'Beginner';
      case ExperienceLevel.intermediate:
        return 'Intermediate';
      case ExperienceLevel.advanced:
        return 'Advanced';
    }
  }
}

/// Prebuilt routine template (read-only)
class PrebuiltRoutine {
  final String id;
  final String name;
  final ExperienceLevel level;
  final int daysPerWeek;
  final List<String> focusAreas;
  final List<RoutineExercise> exercises;
  final String description;

  const PrebuiltRoutine({
    required this.id,
    required this.name,
    required this.level,
    required this.daysPerWeek,
    required this.focusAreas,
    required this.exercises,
    this.description = '',
  });

  /// Convert to user Routine (for saving to My Routines)
  Routine toUserRoutine() {
    return Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      targetFocus: focusAreas,
      exercises: exercises
          .map((e) => RoutineExercise(
                exerciseId: e.exerciseId,
                name: e.name,
                sets: e.sets,
                reps: e.reps,
                restSeconds: e.restSeconds,
              ))
          .toList(),
    );
  }
}

/// Static list of prebuilt routines
final List<PrebuiltRoutine> prebuiltRoutines = [
  // ─────────────────────────────────────────────────────────────────────────
  // BEGINNER
  // ─────────────────────────────────────────────────────────────────────────
  PrebuiltRoutine(
    id: 'beginner_full_body',
    name: 'Full Body Starter',
    level: ExperienceLevel.beginner,
    daysPerWeek: 3,
    focusAreas: ['Full Body'],
    description: 'Perfect for beginners. Hit every muscle group 3x per week.',
    exercises: [
      RoutineExercise(
          exerciseId: 'squat', name: 'Squat', sets: 3, reps: '10-12'),
      RoutineExercise(
          exerciseId: 'push_ups', name: 'Push Ups', sets: 3, reps: '8-12'),
      RoutineExercise(
          exerciseId: 'lat_pulldown',
          name: 'Lat Pulldown',
          sets: 3,
          reps: '10-12'),
      RoutineExercise(
          exerciseId: 'shoulder_press',
          name: 'Shoulder Press',
          sets: 3,
          reps: '10-12'),
      RoutineExercise(exerciseId: 'plank', name: 'Plank', sets: 3, reps: '30s'),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // INTERMEDIATE
  // ─────────────────────────────────────────────────────────────────────────
  PrebuiltRoutine(
    id: 'intermediate_upper_lower',
    name: 'Upper / Lower Split',
    level: ExperienceLevel.intermediate,
    daysPerWeek: 4,
    focusAreas: ['Chest', 'Back', 'Shoulders', 'Quads', 'Hamstrings'],
    description: 'Alternate upper and lower body days for balanced growth.',
    exercises: [
      // Upper
      RoutineExercise(
          exerciseId: 'bench_press',
          name: 'Bench Press',
          sets: 4,
          reps: '8-10'),
      RoutineExercise(
          exerciseId: 'barbell_row',
          name: 'Barbell Row',
          sets: 4,
          reps: '8-10'),
      RoutineExercise(
          exerciseId: 'shoulder_press',
          name: 'Shoulder Press',
          sets: 3,
          reps: '10-12'),
      RoutineExercise(
          exerciseId: 'bicep_curl', name: 'Bicep Curl', sets: 3, reps: '10-12'),
      RoutineExercise(
          exerciseId: 'tricep_pushdown',
          name: 'Tricep Pushdown',
          sets: 3,
          reps: '10-12'),
      // Lower
      RoutineExercise(
          exerciseId: 'squat', name: 'Squat', sets: 4, reps: '8-10'),
      RoutineExercise(
          exerciseId: 'romanian_deadlift',
          name: 'Romanian Deadlift',
          sets: 4,
          reps: '8-10'),
      RoutineExercise(
          exerciseId: 'leg_press', name: 'Leg Press', sets: 3, reps: '10-12'),
      RoutineExercise(
          exerciseId: 'leg_curl', name: 'Leg Curl', sets: 3, reps: '10-12'),
      RoutineExercise(
          exerciseId: 'calf_raise', name: 'Calf Raise', sets: 4, reps: '12-15'),
    ],
  ),
  PrebuiltRoutine(
    id: 'intermediate_ppl',
    name: 'Push / Pull / Legs',
    level: ExperienceLevel.intermediate,
    daysPerWeek: 6,
    focusAreas: [
      'Chest',
      'Back',
      'Shoulders',
      'Biceps',
      'Triceps',
      'Quads',
      'Hamstrings',
      'Glutes'
    ],
    description: 'Classic PPL split for intermediate lifters. High frequency.',
    exercises: [
      // Push
      RoutineExercise(
          exerciseId: 'bench_press', name: 'Bench Press', sets: 4, reps: '6-8'),
      RoutineExercise(
          exerciseId: 'shoulder_press',
          name: 'Shoulder Press',
          sets: 4,
          reps: '8-10'),
      RoutineExercise(
          exerciseId: 'incline_db_press',
          name: 'Incline DB Press',
          sets: 3,
          reps: '10-12'),
      RoutineExercise(
          exerciseId: 'lateral_raise',
          name: 'Lateral Raise',
          sets: 3,
          reps: '12-15'),
      RoutineExercise(
          exerciseId: 'tricep_pushdown',
          name: 'Tricep Pushdown',
          sets: 3,
          reps: '10-12'),
      // Pull
      RoutineExercise(
          exerciseId: 'deadlift', name: 'Deadlift', sets: 4, reps: '5-6'),
      RoutineExercise(
          exerciseId: 'pull_ups', name: 'Pull Ups', sets: 4, reps: '6-10'),
      RoutineExercise(
          exerciseId: 'barbell_row',
          name: 'Barbell Row',
          sets: 4,
          reps: '8-10'),
      RoutineExercise(
          exerciseId: 'face_pull', name: 'Face Pull', sets: 3, reps: '12-15'),
      RoutineExercise(
          exerciseId: 'bicep_curl', name: 'Bicep Curl', sets: 3, reps: '10-12'),
      // Legs
      RoutineExercise(exerciseId: 'squat', name: 'Squat', sets: 4, reps: '6-8'),
      RoutineExercise(
          exerciseId: 'leg_press', name: 'Leg Press', sets: 4, reps: '10-12'),
      RoutineExercise(
          exerciseId: 'romanian_deadlift',
          name: 'Romanian Deadlift',
          sets: 3,
          reps: '10-12'),
      RoutineExercise(
          exerciseId: 'leg_curl', name: 'Leg Curl', sets: 3, reps: '10-12'),
      RoutineExercise(
          exerciseId: 'calf_raise', name: 'Calf Raise', sets: 4, reps: '12-15'),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // ADVANCED
  // ─────────────────────────────────────────────────────────────────────────
  PrebuiltRoutine(
    id: 'advanced_bro_split',
    name: 'Bro Split',
    level: ExperienceLevel.advanced,
    daysPerWeek: 5,
    focusAreas: [
      'Chest',
      'Back',
      'Shoulders',
      'Biceps',
      'Triceps',
      'Quads',
      'Hamstrings'
    ],
    description:
        'Single muscle focus per day. Maximum volume for advanced lifters.',
    exercises: [
      // Chest Day
      RoutineExercise(
          exerciseId: 'bench_press', name: 'Bench Press', sets: 5, reps: '5-8'),
      RoutineExercise(
          exerciseId: 'incline_db_press',
          name: 'Incline DB Press',
          sets: 4,
          reps: '8-10'),
      RoutineExercise(
          exerciseId: 'cable_fly', name: 'Cable Fly', sets: 4, reps: '10-12'),
      // Back Day
      RoutineExercise(
          exerciseId: 'deadlift', name: 'Deadlift', sets: 5, reps: '3-5'),
      RoutineExercise(
          exerciseId: 'pull_ups', name: 'Pull Ups', sets: 4, reps: '8-10'),
      RoutineExercise(
          exerciseId: 'barbell_row',
          name: 'Barbell Row',
          sets: 4,
          reps: '8-10'),
      RoutineExercise(
          exerciseId: 'lat_pulldown',
          name: 'Lat Pulldown',
          sets: 3,
          reps: '10-12'),
      // Shoulder Day
      RoutineExercise(
          exerciseId: 'shoulder_press',
          name: 'Shoulder Press',
          sets: 4,
          reps: '6-8'),
      RoutineExercise(
          exerciseId: 'lateral_raise',
          name: 'Lateral Raise',
          sets: 4,
          reps: '12-15'),
      RoutineExercise(
          exerciseId: 'face_pull', name: 'Face Pull', sets: 3, reps: '12-15'),
      // Arm Day
      RoutineExercise(
          exerciseId: 'bicep_curl', name: 'Bicep Curl', sets: 4, reps: '8-12'),
      RoutineExercise(
          exerciseId: 'hammer_curl',
          name: 'Hammer Curl',
          sets: 3,
          reps: '10-12'),
      RoutineExercise(
          exerciseId: 'tricep_dips',
          name: 'Tricep Dips',
          sets: 4,
          reps: '8-12'),
      RoutineExercise(
          exerciseId: 'skull_crushers',
          name: 'Skull Crushers',
          sets: 3,
          reps: '10-12'),
      // Leg Day
      RoutineExercise(exerciseId: 'squat', name: 'Squat', sets: 5, reps: '5-8'),
      RoutineExercise(
          exerciseId: 'leg_press', name: 'Leg Press', sets: 4, reps: '10-12'),
      RoutineExercise(
          exerciseId: 'leg_curl', name: 'Leg Curl', sets: 4, reps: '10-12'),
      RoutineExercise(
          exerciseId: 'calf_raise', name: 'Calf Raise', sets: 5, reps: '12-15'),
    ],
  ),
];

/// Filter prebuilt routines by experience level
List<PrebuiltRoutine> getRoutinesByLevel(ExperienceLevel level) {
  return prebuiltRoutines.where((r) => r.level == level).toList();
}

/// Get count of prebuilt routines
int get prebuiltRoutineCount => prebuiltRoutines.length;
