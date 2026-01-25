import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/workout_history_service.dart';
import '../../services/muscle_stats_service.dart';
import '../../widgets/monthly_summary.dart';

class MonthlyReportScreen extends StatefulWidget {
  final DateTime monthStart; // Pass current week start to derive month

  const MonthlyReportScreen({
    super.key,
    required this.monthStart,
  });

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final MuscleStatsService _muscleStatsService = MuscleStatsService();

  bool _loading = true;
  MonthlyStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allSessions = _historyService.getAllDetailedSessions();

    final stats = _muscleStatsService.computeMonthlyReport(
        allSessions, widget.monthStart);

    if (mounted) {
      setState(() {
        _stats = stats;
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
        title: const Text('Monthly Report'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent))
          : Padding(
              padding: EdgeInsets.all(GymTheme.spacing.md),
              child: _stats == null
                  ? Center(
                      child: Text('No data', style: GymTheme.text.secondary))
                  : MonthlySummary(
                      workouts: _stats!.workouts,
                      sets: _stats!.totalSets,
                      durationMinutes: _stats!.totalDurationMinutes,
                    ),
            ),
    );
  }
}
