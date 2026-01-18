import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _kHistoryKey = 'gym_app_workout_history';
const int _kMaxHistoryItems = 50;

/// Lightweight history entry for completed workouts
class WorkoutHistoryEntry {
  final String id;
  final String? routineId;
  final String name;
  final DateTime completedAt;
  final Duration duration;
  final int exerciseCount;
  final int totalSets;

  const WorkoutHistoryEntry({
    required this.id,
    this.routineId,
    required this.name,
    required this.completedAt,
    required this.duration,
    required this.exerciseCount,
    required this.totalSets,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'routineId': routineId,
        'name': name,
        'completedAt': completedAt.toIso8601String(),
        'durationSeconds': duration.inSeconds,
        'exerciseCount': exerciseCount,
        'totalSets': totalSets,
      };

  factory WorkoutHistoryEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryEntry(
      id: json['id'] as String,
      routineId: json['routineId'] as String?,
      name: json['name'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      duration: Duration(seconds: json['durationSeconds'] as int),
      exerciseCount: json['exerciseCount'] as int,
      totalSets: json['totalSets'] as int,
    );
  }
}

/// Service for managing workout history persistence
class WorkoutHistoryService {
  static final WorkoutHistoryService _instance =
      WorkoutHistoryService._internal();
  factory WorkoutHistoryService() => _instance;
  WorkoutHistoryService._internal();

  List<WorkoutHistoryEntry> _history = [];
  bool _initialized = false;

  /// Get all history entries (newest first)
  List<WorkoutHistoryEntry> get history => List.unmodifiable(_history);

  /// Get last completed routine id
  String? get lastCompletedRoutineId {
    for (final entry in _history) {
      if (entry.routineId != null) {
        return entry.routineId;
      }
    }
    return null;
  }

  /// Get recent routine ids (last 14 days)
  List<String> getRecentRoutineIds({int days = 14}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _history
        .where((e) => e.routineId != null && e.completedAt.isAfter(cutoff))
        .map((e) => e.routineId!)
        .toList();
  }

  /// Initialize from storage
  Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kHistoryKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _history = jsonList
            .map((e) => WorkoutHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _history = [];
    }

    _initialized = true;
  }

  /// Save history to storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_history.map((e) => e.toJson()).toList());
      await prefs.setString(_kHistoryKey, jsonString);
    } catch (e) {
      // Silently fail
    }
  }

  /// Add a completed workout to history
  Future<void> addEntry(WorkoutHistoryEntry entry) async {
    // Add to front (newest first)
    _history.insert(0, entry);

    // Trim to max size
    if (_history.length > _kMaxHistoryItems) {
      _history = _history.sublist(0, _kMaxHistoryItems);
    }

    await _saveToStorage();
  }

  /// Get recent workouts for display
  List<WorkoutHistoryEntry> getRecentWorkouts({int limit = 5}) {
    return _history.take(limit).toList();
  }
}
