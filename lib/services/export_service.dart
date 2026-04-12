import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/workout_history_service.dart';

class ExportService {
  /// Generate CSV content from workouts
  String _generateCsv(List<WorkoutHistoryEntry> workouts) {
    // UTF-8 BOM for Excel compatibility
    final buffer = StringBuffer('\uFEFF');

    // Header
    buffer.writeln(
        'Date,Time,Routine Name,Duration (min),Total Sets,Exercise Count');

    for (final workout in workouts) {
      final date = workout.completedAt.toIso8601String();
      // Or more readable: YYYY-MM-DD
      // User requested ISO-8601 timestamps.

      final time =
          '${workout.completedAt.hour.toString().padLeft(2, '0')}:${workout.completedAt.minute.toString().padLeft(2, '0')}';

      buffer.write('${_sanitize(date)},');
      buffer.write('${_sanitize(time)},');
      buffer.write('${_sanitize(workout.name)},');
      buffer.write('${(workout.duration.inMinutes).toString()},');
      buffer.write('${workout.totalSets},');
      buffer.writeln('${workout.exerciseCount}');
    }

    return buffer.toString();
  }

  /// Sanitize text fields for CSV (escape quotes, wrap in quotes)
  String _sanitize(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  /// Export workouts to a CSV file and open share sheet
  Future<void> exportWorkouts(List<WorkoutHistoryEntry> workouts,
      {String? filename}) async {
    if (workouts.isEmpty) return;

    final csvContent = _generateCsv(workouts);
    final fileName =
        filename ?? 'workouts_${DateTime.now().millisecondsSinceEpoch}.csv';

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');

    await file.writeAsString(csvContent);

    // Share
    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Here is my workout history export.',
      subject: 'Workout Export',
    );
    // Note: We leave the file in temp; OS clears it eventually.
    // Forcing delete immediately might race with share sheet reading it on some OSs.
  }
}
