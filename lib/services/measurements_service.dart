import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/measurement.dart';

const String _kMeasurementsKey = 'gym_app_measurements';

class MeasurementsService {
  static final MeasurementsService _instance = MeasurementsService._internal();
  factory MeasurementsService() => _instance;
  MeasurementsService._internal();

  List<Measurement> _measurements = [];
  bool _initialized = false;

  /// Initialize and load data
  Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kMeasurementsKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _measurements = jsonList
            .map((e) => Measurement.fromJson(e as Map<String, dynamic>))
            .toList();

        // Sort by logical date descending (newest first)
        _sortMeasurements();
      }
    } catch (e) {
      // Initialize with empty on error
      _measurements = [];
    }

    _initialized = true;
  }

  void _sortMeasurements() {
    _measurements.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString =
          jsonEncode(_measurements.map((e) => e.toJson()).toList());
      await prefs.setString(_kMeasurementsKey, jsonString);
    } catch (e) {
      // Silently fail or log
    }
  }

  // --- CRUD API ---

  List<Measurement> getAll() {
    return List.unmodifiable(_measurements);
  }

  Measurement? getById(String id) {
    try {
      return _measurements.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Measurement measurement) async {
    // Check if updating existing
    final index = _measurements.indexWhere((e) => e.id == measurement.id);

    if (index >= 0) {
      _measurements[index] = measurement.copyWith(updatedAt: DateTime.now());
    } else {
      _measurements.add(measurement);
    }

    _sortMeasurements();
    await _saveToStorage();
  }

  Future<void> delete(String id) async {
    _measurements.removeWhere((e) => e.id == id);
    await _saveToStorage();
  }

  /// Get measurements within logical date range
  List<Measurement> getInRange(DateTime start, DateTime end) {
    // Normalize to start/end of days
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return _measurements.where((m) {
      return m.date.isAfter(s.subtract(const Duration(seconds: 1))) &&
          m.date.isBefore(e.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Get the most recent value for a specific metric
  double? getLatestMetric(MeasurementMetric metric) {
    // Already sorted by date desc
    for (final m in _measurements) {
      final val = m.metrics.getValue(metric);
      if (val != null) {
        return val;
      }
    }
    return null;
  }

  // --- Unit Helpers ---

  static const double _lbsPerKg = 2.20462;
  static const double _cmPerInch = 2.54;

  double kgToLb(double kg) => kg * _lbsPerKg;
  double lbToKg(double lb) => lb / _lbsPerKg;

  double cmToIn(double cm) => cm / _cmPerInch;
  double inToCm(double inch) => inch * _cmPerInch;
}
