import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';

const String _kRoutinesKey = 'gym_app_routines';
const int kFreeRoutineLimit = 3;

/// Singleton service for managing routine persistence
class RoutineStore {
  static final RoutineStore _instance = RoutineStore._internal();
  factory RoutineStore() => _instance;
  RoutineStore._internal();

  List<Routine> _routines = [];
  bool _initialized = false;

  List<Routine> get routines => List.unmodifiable(_routines);
  int get count => _routines.length;
  bool get canAddRoutine => _routines.length < kFreeRoutineLimit;

  Future<void> init() async {
    if (_initialized) return;
    await _loadFromStorage();
    _initialized = true;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kRoutinesKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        _routines = Routine.decodeList(jsonString);
      }
    } catch (e) {
      _routines = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = Routine.encodeList(_routines);
      await prefs.setString(_kRoutinesKey, jsonString);
    } catch (e) {
      // Silently fail
    }
  }

  Future<bool> saveRoutine(Routine routine) async {
    if (!canAddRoutine) return false;
    _routines.add(routine);
    await _saveToStorage();
    return true;
  }

  Routine? getRoutineById(String id) {
    try {
      return _routines.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() async {
    await _loadFromStorage();
  }

  Future<bool> deleteRoutine(String id) async {
    final index = _routines.indexWhere((r) => r.id == id);
    if (index == -1) return false;
    _routines.removeAt(index);
    await _saveToStorage();
    return true;
  }
}
