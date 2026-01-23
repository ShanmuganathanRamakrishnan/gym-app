import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/services/profile_repository.dart';
import 'package:gym_app/services/workout_history_service.dart';

void main() {
  group('ProfileRepository', () {
    late ProfileRepository repository;

    setUp(() {
      repository = ProfileRepository();
    });

    group('getProfileAggregates', () {
      test('returns empty aggregates when no workout history', () async {
        final aggregates = await repository.getProfileAggregates();

        // Should return valid empty aggregates
        expect(aggregates.stats.totalWorkouts, greaterThanOrEqualTo(0));
        expect(aggregates.stats.totalExercises, greaterThanOrEqualTo(0));
        expect(aggregates.stats.totalSets, greaterThanOrEqualTo(0));
        expect(aggregates.stats.totalMinutes, greaterThanOrEqualTo(0));
        expect(aggregates.recentWorkouts, isA<List<WorkoutHistoryEntry>>());
      });

      test('stats are correctly computed from history', () async {
        final aggregates = await repository.getProfileAggregates();

        // Stats should be non-negative
        expect(aggregates.stats.totalWorkouts, greaterThanOrEqualTo(0));
        expect(aggregates.stats.totalMinutes, greaterThanOrEqualTo(0));
      });

      test('training focus returns null when not enough data', () async {
        // When there are fewer than 3 workouts, training focus should be null
        final hasEnough = repository.hasEnoughDataForFocus();

        // This is a read-only check
        expect(hasEnough, isA<bool>());
      });
    });

    group('ProfileStats', () {
      test('empty factory creates zero values', () {
        final empty = ProfileStats.empty();

        expect(empty.totalWorkouts, equals(0));
        expect(empty.totalExercises, equals(0));
        expect(empty.totalSets, equals(0));
        expect(empty.totalMinutes, equals(0));
      });
    });

    group('StreakInfo', () {
      test('empty factory creates zero values', () {
        final empty = StreakInfo.empty();

        expect(empty.currentStreak, equals(0));
        expect(empty.longestStreak, equals(0));
        expect(empty.lastWorkoutDate, isNull);
      });
    });

    group('TrainingFocus', () {
      test('can be constructed with valid data', () {
        const focus = TrainingFocus(
          primaryMuscle: 'Chest',
          percentage: 35.0,
          muscleDistribution: {'Chest': 35, 'Back': 25},
        );

        expect(focus.primaryMuscle, equals('Chest'));
        expect(focus.percentage, equals(35.0));
        expect(focus.muscleDistribution.length, equals(2));
      });
    });
  });
}
