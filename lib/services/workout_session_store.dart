import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_session.dart';

const String _kActiveSessionKey = 'gym_app_active_session';

/// Service for managing workout session persistence
/// Supports autosave and session recovery after app backgrounding
class WorkoutSessionStore {
  static final WorkoutSessionStore _instance = WorkoutSessionStore._internal();
  factory WorkoutSessionStore() => _instance;
  WorkoutSessionStore._internal();

  WorkoutSession? _activeSession;
  bool _initialized = false;

  /// Get current active session
  WorkoutSession? get activeSession => _activeSession;

  /// Check if there's an active session
  bool get hasActiveSession => _activeSession != null;

  Future<void> init() async {
    if (_initialized) return;
    await _loadActiveSession();
    _initialized = true;
  }

  /// Load active session from storage (for recovery)
  Future<void> _loadActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kActiveSessionKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        _activeSession = WorkoutSession.decode(jsonString);
      }
    } catch (e) {
      _activeSession = null;
    }
  }

  /// Save active session to storage (autosave)
  Future<void> _saveActiveSession() async {
    if (_activeSession == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = WorkoutSession.encode(_activeSession!);
      await prefs.setString(_kActiveSessionKey, jsonString);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear active session from storage
  Future<void> _clearActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kActiveSessionKey);
    } catch (e) {
      // Silently fail
    }
  }

  /// Start a new workout session
  Future<WorkoutSession> startSession({
    String? routineId,
    required String name,
    List<WorkoutExercise>? exercises,
  }) async {
    _activeSession = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routineId: routineId,
      name: name,
      startTime: DateTime.now(),
      exercises: exercises ?? [],
    );
    await _saveActiveSession();
    return _activeSession!;
  }

  /// Update session and autosave
  Future<void> updateSession(WorkoutSession session) async {
    _activeSession = session;
    await _saveActiveSession();
  }

  /// Pause the active session
  Future<void> pauseSession() async {
    if (_activeSession == null || _activeSession!.isPaused) return;
    _activeSession!.isPaused = true;
    _activeSession!.pauseStartTime = DateTime.now();
    await _saveActiveSession();
  }

  /// Resume the active session
  Future<void> resumeSession() async {
    if (_activeSession == null || !_activeSession!.isPaused) return;
    if (_activeSession!.pauseStartTime != null) {
      final pausedTime =
          DateTime.now().difference(_activeSession!.pauseStartTime!);
      _activeSession!.pausedDuration += pausedTime;
    }
    _activeSession!.isPaused = false;
    _activeSession!.pauseStartTime = null;
    await _saveActiveSession();
  }

  /// End the active session
  Future<WorkoutSession> endSession() async {
    if (_activeSession == null) {
      throw StateError('No active session to end');
    }

    // Handle any remaining pause time
    if (_activeSession!.isPaused && _activeSession!.pauseStartTime != null) {
      final pausedTime =
          DateTime.now().difference(_activeSession!.pauseStartTime!);
      _activeSession!.pausedDuration += pausedTime;
    }

    _activeSession!.endTime = DateTime.now();
    _activeSession!.isPaused = false;
    _activeSession!.pauseStartTime = null;

    final completedSession = _activeSession!;
    await _clearActiveSession();
    _activeSession = null;

    // TODO: Save to history if needed
    return completedSession;
  }

  /// Discard the active session without saving
  Future<void> discardSession() async {
    await _clearActiveSession();
    _activeSession = null;
  }

  /// Add exercise to active session
  Future<void> addExercise(WorkoutExercise exercise) async {
    if (_activeSession == null) return;
    _activeSession!.exercises.add(exercise);
    await _saveActiveSession();
  }

  /// Remove exercise from active session
  Future<void> removeExercise(String exerciseId) async {
    if (_activeSession == null) return;
    _activeSession!.exercises.removeWhere((e) => e.id == exerciseId);
    await _saveActiveSession();
  }

  /// Update a set in an exercise
  Future<void> updateSet({
    required String exerciseId,
    required int setIndex,
    int? reps,
    double? weight,
    bool? completed,
  }) async {
    if (_activeSession == null) return;

    final exerciseIndex =
        _activeSession!.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = _activeSession!.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    if (reps != null) set.reps = reps;
    if (weight != null) set.weight = weight;
    if (completed != null) {
      set.completed = completed;
      if (completed) {
        set.completedAt = DateTime.now();
      }
    }

    await _saveActiveSession();
  }

  /// Add a new set to an exercise
  Future<void> addSet(String exerciseId) async {
    if (_activeSession == null) return;

    final exerciseIndex =
        _activeSession!.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = _activeSession!.exercises[exerciseIndex];
    final newSetNumber = exercise.sets.length + 1;
    exercise.sets.add(WorkoutSet(setNumber: newSetNumber));

    await _saveActiveSession();
  }

  /// Skip an exercise
  Future<void> skipExercise(String exerciseId) async {
    if (_activeSession == null) return;

    final exerciseIndex =
        _activeSession!.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    _activeSession!.exercises[exerciseIndex].skipped = true;
    await _saveActiveSession();
  }
}
