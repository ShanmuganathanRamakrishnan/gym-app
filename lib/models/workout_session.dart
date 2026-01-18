import 'dart:convert';

/// Model representing a single set within an exercise
class WorkoutSet {
  int setNumber;
  int reps;
  double weight;
  bool completed;
  DateTime? completedAt;

  WorkoutSet({
    required this.setNumber,
    this.reps = 0,
    this.weight = 0,
    this.completed = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'reps': reps,
        'weight': weight,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      setNumber: json['setNumber'] as int,
      reps: json['reps'] as int? ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  WorkoutSet copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    bool? completed,
    DateTime? completedAt,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Model representing an exercise within a workout session
class WorkoutExercise {
  final String id;
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final String targetReps; // From routine, e.g., '8-12'
  List<WorkoutSet> sets;
  bool skipped;

  WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.name,
    this.muscleGroup = '',
    this.targetReps = '',
    List<WorkoutSet>? sets,
    this.skipped = false,
  }) : sets = sets ??
            [
              WorkoutSet(setNumber: 1),
              WorkoutSet(setNumber: 2),
              WorkoutSet(setNumber: 3)
            ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseId': exerciseId,
        'name': name,
        'muscleGroup': muscleGroup,
        'targetReps': targetReps,
        'sets': sets.map((s) => s.toJson()).toList(),
        'skipped': skipped,
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String? ?? '',
      targetReps: json['targetReps'] as String? ?? '',
      sets: (json['sets'] as List?)
              ?.map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      skipped: json['skipped'] as bool? ?? false,
    );
  }

  /// Get completed sets count
  int get completedSetsCount => sets.where((s) => s.completed).length;

  /// Check if all sets are completed
  bool get isComplete => sets.isNotEmpty && sets.every((s) => s.completed);
}

/// Model representing a workout session
class WorkoutSession {
  final String id;
  final String? routineId;
  final String name;
  DateTime startTime;
  DateTime? endTime;
  Duration pausedDuration;
  List<WorkoutExercise> exercises;
  bool isPaused;
  DateTime? pauseStartTime;

  WorkoutSession({
    required this.id,
    this.routineId,
    required this.name,
    required this.startTime,
    this.endTime,
    Duration? pausedDuration,
    List<WorkoutExercise>? exercises,
    this.isPaused = false,
    this.pauseStartTime,
  })  : pausedDuration = pausedDuration ?? Duration.zero,
        exercises = exercises ?? [];

  /// Check if this is a freestyle workout
  bool get isFreestyle => routineId == null;

  /// Get total duration (excluding paused time)
  Duration get totalDuration {
    final end = endTime ?? DateTime.now();
    var total = end.difference(startTime);
    total -= pausedDuration;
    if (isPaused && pauseStartTime != null) {
      total -= DateTime.now().difference(pauseStartTime!);
    }
    return total < Duration.zero ? Duration.zero : total;
  }

  /// Get completed exercises count
  int get completedExercisesCount =>
      exercises.where((e) => e.isComplete && !e.skipped).length;

  /// Get total sets completed
  int get totalSetsCompleted =>
      exercises.fold(0, (sum, e) => sum + e.completedSetsCount);

  Map<String, dynamic> toJson() => {
        'id': id,
        'routineId': routineId,
        'name': name,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'pausedDuration': pausedDuration.inSeconds,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'isPaused': isPaused,
        'pauseStartTime': pauseStartTime?.toIso8601String(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      routineId: json['routineId'] as String?,
      name: json['name'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      pausedDuration: Duration(seconds: json['pausedDuration'] as int? ?? 0),
      exercises: (json['exercises'] as List?)
              ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isPaused: json['isPaused'] as bool? ?? false,
      pauseStartTime: json['pauseStartTime'] != null
          ? DateTime.parse(json['pauseStartTime'] as String)
          : null,
    );
  }

  static String encode(WorkoutSession session) {
    return jsonEncode(session.toJson());
  }

  static WorkoutSession decode(String jsonString) {
    return WorkoutSession.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
