import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/workout_history_service.dart';
import '../../services/muscle_stats_service.dart';
import '../../models/muscle_selector_mapping.dart';

class SetCountScreen extends StatefulWidget {
  final DateTime weekStart;
  final DateTime weekEnd;

  const SetCountScreen({
    super.key,
    required this.weekStart,
    required this.weekEnd,
  });

  @override
  State<SetCountScreen> createState() => _SetCountScreenState();
}

class _SetCountScreenState extends State<SetCountScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final MuscleStatsService _muscleStatsService = MuscleStatsService();

  bool _loading = true;
  Map<InternalMuscle, double> _muscleLoad = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Fetch all sessions (or filtered query if service supported it)
    final allSessions = _historyService.getAllDetailedSessions();

    // Filter locally
    final filtered = allSessions.where((s) {
      if (s.endTime == null) return false;
      return s.endTime!.isAfter(widget.weekStart) &&
          s.endTime!.isBefore(widget.weekEnd);
    }).toList();

    // Compute load
    final load = _muscleStatsService.computeMuscleLoad(filtered);

    if (mounted) {
      setState(() {
        _muscleLoad = load;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        title: const Text('Set Count per Muscle'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent))
          : _muscleLoad.isEmpty
              ? Center(
                  child: Text('No data for this period',
                      style: GymTheme.text.secondary))
              : ListView.separated(
                  padding: EdgeInsets.all(GymTheme.spacing.md),
                  itemCount: _muscleLoad.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: GymTheme.colors.divider),
                  itemBuilder: (context, index) {
                    final sortedEntries = _muscleLoad.entries.toList()
                      ..sort(
                          (a, b) => b.value.compareTo(a.value)); // Descending
                    final entry = sortedEntries[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        entry.key.name.toUpperCase(),
                        style: TextStyle(color: GymTheme.colors.textPrimary),
                      ),
                      trailing: Text(
                        '${entry.value.toInt()} sets',
                        style: TextStyle(
                          color: GymTheme.colors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
