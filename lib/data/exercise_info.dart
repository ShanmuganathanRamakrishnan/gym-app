/// Exercise demo/info data for the MVP
class ExerciseInfo {
  final String id;
  final String name;
  final String primaryMuscle;
  final String description;
  final List<String> formCues;
  final String? assetPath; // Local asset (Lottie JSON or GIF)
  final bool hasDemo;

  const ExerciseInfo({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.description,
    required this.formCues,
    this.assetPath,
    this.hasDemo = false,
  });
}

/// Exercise info database with form cues and demo assets
/// MVP: Starter set of common exercises
final Map<String, ExerciseInfo> exerciseInfoDatabase = {
  // ── CHEST ──────────────────────────────────────────────────────────────────
  'bench_press': const ExerciseInfo(
    id: 'bench_press',
    name: 'Bench Press',
    primaryMuscle: 'Chest',
    description:
        'The bench press is a compound exercise that targets the chest, shoulders, and triceps. It\'s one of the most effective exercises for building upper body strength.',
    formCues: [
      'Keep your feet flat on the floor',
      'Squeeze your shoulder blades together',
      'Lower the bar to mid-chest level',
      'Drive through your heels as you press up',
    ],
    assetPath: 'assets/exercises/bench_press_placeholder.png',
    hasDemo: true,
  ),
  'incline_db_press': const ExerciseInfo(
    id: 'incline_db_press',
    name: 'Incline Dumbbell Press',
    primaryMuscle: 'Upper Chest',
    description:
        'An incline variation that emphasizes the upper chest fibers. Great for building a fuller chest.',
    formCues: [
      'Set bench to 30-45 degree angle',
      'Keep elbows at 45 degrees to body',
      'Press dumbbells up and slightly inward',
      'Control the descent slowly',
    ],
  ),
  'cable_fly': const ExerciseInfo(
    id: 'cable_fly',
    name: 'Cable Fly',
    primaryMuscle: 'Chest',
    description:
        'An isolation exercise that stretches and contracts the chest through a full range of motion.',
    formCues: [
      'Slight bend in elbows throughout',
      'Bring hands together in an arc motion',
      'Squeeze chest at the top',
      'Control the weight on the way back',
    ],
  ),

  // ── BACK ───────────────────────────────────────────────────────────────────
  'deadlift': const ExerciseInfo(
    id: 'deadlift',
    name: 'Deadlift',
    primaryMuscle: 'Back / Posterior Chain',
    description:
        'A fundamental compound lift that builds total body strength. Targets the entire posterior chain including back, glutes, and hamstrings.',
    formCues: [
      'Bar over mid-foot, shoulder-width stance',
      'Hinge at hips, keep back neutral',
      'Drive through heels, squeeze glutes at top',
      'Lower by hinging hips back first',
    ],
    assetPath: 'assets/exercises/deadlift_placeholder.png',
    hasDemo: true,
  ),
  'lat_pulldown': const ExerciseInfo(
    id: 'lat_pulldown',
    name: 'Lat Pulldown',
    primaryMuscle: 'Lats',
    description:
        'A machine exercise that mimics pull-up motion. Great for building back width.',
    formCues: [
      'Grip slightly wider than shoulders',
      'Pull bar to upper chest',
      'Squeeze lats at the bottom',
      'Control the weight on the way up',
    ],
  ),
  'barbell_row': const ExerciseInfo(
    id: 'barbell_row',
    name: 'Barbell Row',
    primaryMuscle: 'Back',
    description:
        'A compound pulling exercise that builds back thickness and strength.',
    formCues: [
      'Hinge forward 45 degrees',
      'Pull bar to lower chest/upper abs',
      'Keep elbows close to body',
      'Squeeze shoulder blades at top',
    ],
  ),

  // ── SHOULDERS ──────────────────────────────────────────────────────────────
  'shoulder_press': const ExerciseInfo(
    id: 'shoulder_press',
    name: 'Shoulder Press',
    primaryMuscle: 'Shoulders',
    description:
        'An overhead pressing movement that builds shoulder strength and size.',
    formCues: [
      'Start with dumbbells at shoulder height',
      'Press straight up overhead',
      'Keep core tight throughout',
      'Don\'t arch lower back excessively',
    ],
  ),
  'lateral_raise': const ExerciseInfo(
    id: 'lateral_raise',
    name: 'Lateral Raise',
    primaryMuscle: 'Side Deltoids',
    description:
        'An isolation exercise that targets the side deltoids for wider shoulders.',
    formCues: [
      'Slight bend in elbows',
      'Raise arms to shoulder height',
      'Lead with elbows, not hands',
      'Control the lowering phase',
    ],
  ),
  'face_pull': const ExerciseInfo(
    id: 'face_pull',
    name: 'Face Pull',
    primaryMuscle: 'Rear Deltoids',
    description:
        'An excellent exercise for shoulder health and rear delt development.',
    formCues: [
      'Pull rope towards face',
      'Separate hands at the end',
      'Squeeze rear delts and upper back',
      'Keep elbows high throughout',
    ],
  ),

  // ── LEGS ───────────────────────────────────────────────────────────────────
  'squat': const ExerciseInfo(
    id: 'squat',
    name: 'Squat',
    primaryMuscle: 'Quads / Glutes',
    description:
        'The king of leg exercises. Builds overall leg strength and muscle mass.',
    formCues: [
      'Feet shoulder-width or slightly wider',
      'Keep chest up, core braced',
      'Descend until thighs parallel to floor',
      'Drive through whole foot to stand',
    ],
    assetPath: 'assets/exercises/squat_placeholder.png',
    hasDemo: true,
  ),
  'leg_press': const ExerciseInfo(
    id: 'leg_press',
    name: 'Leg Press',
    primaryMuscle: 'Quads',
    description:
        'A machine-based compound movement for building leg strength safely.',
    formCues: [
      'Feet shoulder-width on platform',
      'Lower weight with control',
      'Don\'t lock knees at top',
      'Keep lower back pressed into pad',
    ],
  ),
  'romanian_deadlift': const ExerciseInfo(
    id: 'romanian_deadlift',
    name: 'Romanian Deadlift',
    primaryMuscle: 'Hamstrings',
    description: 'A hip-hinge movement that targets hamstrings and glutes.',
    formCues: [
      'Slight knee bend, hinge at hips',
      'Lower bar along thighs',
      'Feel stretch in hamstrings',
      'Squeeze glutes to return up',
    ],
  ),
  'leg_curl': const ExerciseInfo(
    id: 'leg_curl',
    name: 'Leg Curl',
    primaryMuscle: 'Hamstrings',
    description: 'An isolation exercise for directly targeting the hamstrings.',
    formCues: [
      'Curl pad toward glutes',
      'Squeeze at the top',
      'Lower with control',
      'Keep hips pressed into pad',
    ],
  ),

  // ── ARMS ───────────────────────────────────────────────────────────────────
  'tricep_pushdown': const ExerciseInfo(
    id: 'tricep_pushdown',
    name: 'Tricep Pushdown',
    primaryMuscle: 'Triceps',
    description:
        'A cable exercise that isolates the triceps for arm development.',
    formCues: [
      'Keep elbows pinned to sides',
      'Push down until arms fully extended',
      'Squeeze triceps at bottom',
      'Control the return slowly',
    ],
  ),
  'overhead_extension': const ExerciseInfo(
    id: 'overhead_extension',
    name: 'Overhead Tricep Extension',
    primaryMuscle: 'Triceps',
    description:
        'Targets the long head of the triceps for complete arm development.',
    formCues: [
      'Keep elbows pointing forward',
      'Lower weight behind head',
      'Extend arms fully overhead',
      'Don\'t let elbows flare out',
    ],
  ),
  'bicep_curl': const ExerciseInfo(
    id: 'bicep_curl',
    name: 'Bicep Curl',
    primaryMuscle: 'Biceps',
    description:
        'The classic arm exercise for building bicep size and strength.',
    formCues: [
      'Keep elbows stationary',
      'Curl weight up with control',
      'Squeeze at the top',
      'Lower slowly to full extension',
    ],
  ),

  // ── CORE ───────────────────────────────────────────────────────────────────
  'plank': const ExerciseInfo(
    id: 'plank',
    name: 'Plank',
    primaryMuscle: 'Core',
    description:
        'An isometric exercise that builds core stability and endurance.',
    formCues: [
      'Elbows under shoulders',
      'Body in straight line',
      'Squeeze glutes and core',
      'Don\'t let hips sag or pike up',
    ],
    assetPath: 'assets/exercises/plank_placeholder.png',
    hasDemo: true,
  ),
};

/// Get exercise info by ID, with fallback for unknown exercises
ExerciseInfo getExerciseInfo(String exerciseId, String fallbackName) {
  return exerciseInfoDatabase[exerciseId] ??
      ExerciseInfo(
        id: exerciseId,
        name: fallbackName,
        primaryMuscle: 'General',
        description:
            'Perform this exercise with proper form and controlled movement.',
        formCues: [
          'Maintain proper posture',
          'Control the movement',
          'Breathe steadily',
          'Focus on the target muscle',
        ],
      );
}
