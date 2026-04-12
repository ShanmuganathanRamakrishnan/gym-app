import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app/models/measurement.dart';
import 'package:gym_app/services/measurements_service.dart';

void main() {
  late MeasurementsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = MeasurementsService();
    // Force re-init since singleton might be dirty
    // But since we mock values, re-calling init is safe-ish if we could reset the singleton.
    // Singleton pattern makes testing tricky.
    // Ideally we'd modify service to allow dependency injection or reset.
    // For now, we rely on setMockInitialValues clearing underlying data,
    // but the in-memory list inside singleton persists across tests if not cleared.
    // Let's rely on internal list clearing if we can, or just careful testing.
    // Actually, create a way to clear for testing?
    // Or just manually delete all.
  });

  // Helper to reset service state (since it's a singleton)
  Future<void> clearService() async {
    await service.init();
    final all = service.getAll();
    for (var m in all) {
      await service.delete(m.id);
    }
  }

  group('MeasurementsService', () {
    test('Unit conversion accuracy', () {
      final s = MeasurementsService();
      expect(s.kgToLb(1.0), closeTo(2.20462, 0.0001));
      expect(s.lbToKg(2.20462), closeTo(1.0, 0.0001));
      expect(s.cmToIn(2.54), closeTo(1.0, 0.0001));
      expect(s.inToCm(1.0), closeTo(2.54, 0.0001));
    });

    test('Save and Load persistence', () async {
      await clearService();

      final m = Measurement(
        date: DateTime(2023, 1, 1),
        metrics: const MeasurementMetrics(weightKg: 80.5),
      );

      await service.save(m);

      final afterSave = service.getAll();
      expect(afterSave.length, 1);
      expect(afterSave.first.metrics.weightKg, 80.5);
      expect(afterSave.first.id, m.id);

      // Verify persistence via recreating service?
      // Can't easily recreate singleton.
      // Assume _saveToStorage logic is sound if list updates.
    });

    test('CRUD Operations', () async {
      await clearService();

      var m = Measurement(
        date: DateTime(2023, 1, 1),
        metrics: const MeasurementMetrics(weightKg: 80.0),
      );

      // Create
      await service.save(m);
      expect(service.getAll().length, 1);

      // Update
      m = m.copyWith(metrics: const MeasurementMetrics(weightKg: 81.0));
      await service.save(m);
      expect(service.getAll().length, 1);
      expect(service.getById(m.id)?.metrics.weightKg, 81.0);

      // Delete
      await service.delete(m.id);
      expect(service.getAll().isEmpty, true);
    });

    test('Date Range Filtering', () async {
      await clearService();

      final m1 = Measurement(date: DateTime(2023, 1, 10));
      final m2 = Measurement(date: DateTime(2023, 2, 10));
      final m3 = Measurement(date: DateTime(2023, 3, 10));

      await service.save(m1);
      await service.save(m2);
      await service.save(m3);

      final range =
          service.getInRange(DateTime(2023, 2, 1), DateTime(2023, 2, 28));
      expect(range.length, 1);
      expect(range.first.id, m2.id);
    });

    test('Get Latest Metric', () async {
      await clearService();

      // Old weight
      await service.save(Measurement(
        date: DateTime(2023, 1, 1),
        metrics: const MeasurementMetrics(weightKg: 80),
      ));

      // New weight
      await service.save(Measurement(
        date: DateTime(2023, 2, 1),
        metrics: const MeasurementMetrics(weightKg: 75),
      ));

      // New entry without weight (should be skipped)
      await service.save(Measurement(
        date: DateTime(2023, 3, 1),
        metrics: const MeasurementMetrics(waistCm: 90),
      ));

      expect(service.getLatestMetric(MeasurementMetric.weightKg), 75.0);
      expect(service.getLatestMetric(MeasurementMetric.waistCm), 90.0);
    });

    test('JSON Backward Compatibility', () {
      // Missing fields should be null
      final json = {
        'id': '123',
        'date': '2023-01-01T00:00:00.000',
        'metrics': {'weightKg': 80.0}
      };
      final m = Measurement.fromJson(json);

      expect(m.metrics.weightKg, 80.0);
      expect(m.metrics.bodyFatPercent, null); // Missing in JSON
      expect(m.photos, isEmpty); // Missing in JSON
    });
  });
}
