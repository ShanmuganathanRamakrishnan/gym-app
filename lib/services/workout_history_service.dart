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

  /// Get recent workouts grouped by routineId + date
  List<GroupedHistoryEntry> getGroupedRecentWorkouts({int limit = 5}) {
    final Map<String, GroupedHistoryEntry> groups = {};

    for (final entry in _history) {
      final dateKey = _dateKey(entry.completedAt);
      // Group key: routineId (or 'freestyle_<id>' for freestyle) + date
      final groupKey = '${entry.routineId ?? 'freestyle_${entry.id}'}_$dateKey';

      if (groups.containsKey(groupKey)) {
        groups[groupKey]!.addEntry(entry);
      } else {
        groups[groupKey] = GroupedHistoryEntry(
          name: entry.name,
          routineId: entry.routineId,
          date: entry.completedAt,
          entries: [entry],
        );
      }
    }

    // Sort by most recent date and take limit
    final sorted = groups.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  /// Helper to get date key (YYYY-MM-DD)
  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

/// Grouped history entry (multiple sessions of same routine on same day)
class GroupedHistoryEntry {
  final String name;
  final String? routineId;
  final DateTime date;
  final List<WorkoutHistoryEntry> entries;

  GroupedHistoryEntry({
    required this.name,
    this.routineId,
    required this.date,
    required List<WorkoutHistoryEntry> entries,
  }) : entries = List.from(entries);

  void addEntry(WorkoutHistoryEntry entry) => entries.add(entry);

  /// Number of sessions in this group
  int get sessionCount => entries.length;

  /// Whether this is a single session or grouped
  bool get isGrouped => entries.length > 1;

  /// Whether this is a freestyle workout
  bool get isFreestyle => routineId == null;

  /// Total duration across all sessions
  Duration get totalDuration =>
      entries.fold(Duration.zero, (sum, e) => sum + e.duration);

  /// Total exercises across all sessions
  int get totalExercises => entries.fold(0, (sum, e) => sum + e.exerciseCount);

  /// Total sets across all sessions
  int get totalSets => entries.fold(0, (sum, e) => sum + e.totalSets);

  /// Most recent completion time
  DateTime get latestCompletedAt =>
      entries.map((e) => e.completedAt).reduce((a, b) => a.isAfter(b) ? a : b);
}
