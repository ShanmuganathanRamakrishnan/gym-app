import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';

/// Storage key for routines
const String _kRoutinesKey = 'gym_app_routines';

/// Maximum number of routines for free users
const int kFreeRoutineLimit = 3;

/// Singleton service for managing routine persistence
/// Storage implementation is fully isolated - swap SharedPreferences
/// for another backend without touching UI code
class RoutineStore {
  static final RoutineStore _instance = RoutineStore._internal();
  factory RoutineStore() => _instance;
  RoutineStore._internal();

  List<Routine> _routines = [];
  bool _initialized = false;

  /// Get current routines (in-memory cache)
  List<Routine> get routines => List.unmodifiable(_routines);

  /// Get count of stored routines
  int get count => _routines.length;

  /// Check if user can add more routines (under free limit)
  bool get canAddRoutine => _routines.length < kFreeRoutineLimit;

  /// Initialize store - must be called before use
  Future<void> init() async {
    if (_initialized) return;
    await _loadFromStorage();
    _initialized = true;
  }

  /// Load routines from persistent storage
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kRoutinesKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        _routines = Routine.decodeList(jsonString);
      }
    } catch (e) {
      // On error, start fresh
      _routines = [];
    }
  }

  /// Save routines to persistent storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = Routine.encodeList(_routines);
      await prefs.setString(_kRoutinesKey, jsonString);
    } catch (e) {
      // Silently fail - routines still in memory
    }
  }

  /// Add a new routine
  /// Returns true if successful, false if limit reached
  Future<bool> saveRoutine(Routine routine) async {
    if (!canAddRoutine) return false;

    _routines.add(routine);
    await _saveToStorage();
    return true;
  }

  /// Get a routine by ID
  Routine? getRoutineById(String id) {
    try {
      return _routines.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Force reload from storage (useful after app resume)
  Future<void> refresh() async {
    await _loadFromStorage();
  }

  /// Delete a routine by ID (for future use)
  Future<bool> deleteRoutine(String id) async {
    final index = _routines.indexWhere((r) => r.id == id);
    if (index == -1) return false;

    _routines.removeAt(index);
    await _saveToStorage();
    return true;
  }
}
