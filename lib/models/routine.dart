import 'dart:convert';

/// Model representing an exercise within a routine
class RoutineExercise {
  final String exerciseId;
  final String name;
  int sets;
  String reps;
  int restSeconds;

  RoutineExercise({
    required this.exerciseId,
    required this.name,
    this.sets = 3,
    this.reps = '8-12',
    this.restSeconds = 60,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'name': name,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
      };

  factory RoutineExercise.fromJson(Map<String, dynamic> json) {
    return RoutineExercise(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as String? ?? '8-12',
      restSeconds: json['restSeconds'] as int? ?? 60,
    );
  }

  RoutineExercise copyWith({
    String? exerciseId,
    String? name,
    int? sets,
    String? reps,
    int? restSeconds,
  }) {
    return RoutineExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}

/// Model representing a workout routine
class Routine {
  final String id;
  final String name;
  final List<String> targetFocus;
  final List<RoutineExercise> exercises;
  final DateTime createdAt;

  Routine({
    required this.id,
    required this.name,
    required this.targetFocus,
    required this.exercises,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get exerciseCount => exercises.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetFocus': targetFocus,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String,
      name: json['name'] as String,
      targetFocus: (json['targetFocus'] as List).cast<String>(),
      exercises: (json['exercises'] as List)
          .map((e) => RoutineExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static String encodeList(List<Routine> routines) {
    return jsonEncode(routines.map((r) => r.toJson()).toList());
  }

  static List<Routine> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => Routine.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
