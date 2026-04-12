import '../services/workout_history_service.dart';

class CalendarService {
  final WorkoutHistoryService _historyService;

  CalendarService({WorkoutHistoryService? historyService})
      : _historyService = historyService ?? WorkoutHistoryService();

  /// Get map of Date -> List of Valid Entries for a specific month
  /// [month] should be any date within the target month
  Future<Map<DateTime, List<WorkoutHistoryEntry>>> getEventsForMonth(
      DateTime month) async {
    // Ensure history is loaded
    await _historyService.init();

    final allHistory = _historyService.history;
    final Map<DateTime, List<WorkoutHistoryEntry>> events = {};

    // Filter for valid entries only (Same logic as getGroupedRecentWorkouts)
    final validEntries = allHistory.where((e) {
      return e.hasLoggedData || e.duration.inMinutes >= 5;
    });

    for (final entry in validEntries) {
      // Normalize to date (YYYY-MM-DD)
      final date = DateTime(
        entry.completedAt.year,
        entry.completedAt.month,
        entry.completedAt.day,
      );

      // Check if matches month (optional optimization, but good to filter)
      // Actually we can return all valid history mapped by date,
      // or just filter for the requested month.
      // Returning all is easier for paging.
      if (events.containsKey(date)) {
        events[date]!.add(entry);
      } else {
        events[date] = [entry];
      }
    }

    return events;
  }

  /// Get lightweight Set of dates that have valid workouts for a specific year
  Future<Set<DateTime>> getActiveDaysForYear(int year) async {
    await _historyService.init();
    final allHistory = _historyService.history;
    final Set<DateTime> activeDays = {};

    // Filter for valid entries and matching year
    final validEntries = allHistory.where((e) {
      if (e.completedAt.year != year) return false;
      return e.hasLoggedData || e.duration.inMinutes >= 5;
    });

    for (final entry in validEntries) {
      activeDays.add(DateTime(
        entry.completedAt.year,
        entry.completedAt.month,
        entry.completedAt.day,
      ));
    }

    return activeDays;
  }

  /// Get list of valid workouts within a specific date range (inclusive)
  Future<List<WorkoutHistoryEntry>> getEventsInRange(
      DateTime start, DateTime end) async {
    await _historyService.init();
    final allHistory = _historyService.history;

    // Normalize range to start of day / end of day
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final entries = allHistory.where((e) {
      if (e.completedAt.isBefore(startOfDay) ||
          e.completedAt.isAfter(endOfDay)) {
        return false;
      }
      return e.hasLoggedData || e.duration.inMinutes >= 5;
    }).toList();

    // Sort ascending by date for export
    entries.sort((a, b) => a.completedAt.compareTo(b.completedAt));

    return entries;
  }
}
