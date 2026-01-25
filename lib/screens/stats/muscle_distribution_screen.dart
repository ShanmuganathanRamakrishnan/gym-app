import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/workout_history_service.dart';
import '../../services/muscle_stats_service.dart';
import '../../widgets/distribution_chart.dart';

class MuscleDistributionScreen extends StatefulWidget {
  final DateTime weekStart;
  final DateTime weekEnd;

  const MuscleDistributionScreen({
    super.key,
    required this.weekStart,
    required this.weekEnd,
  });

  @override
  State<MuscleDistributionScreen> createState() =>
      _MuscleDistributionScreenState();
}

class _MuscleDistributionScreenState extends State<MuscleDistributionScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final MuscleStatsService _muscleStatsService = MuscleStatsService();

  bool _loading = true;
  Map<String, double> _distribution = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allSessions = _historyService.getAllDetailedSessions();

    // Service handles filtering inside computeMuscleDistribution if we pass dates,
    // but looking at valid implementation, computeMuscleDistribution takes dates.
    // Let's verify service signature.
    // computeMuscleDistribution(List sessions, start, end)

    final distMap = _muscleStatsService.computeMuscleDistribution(
        allSessions, widget.weekStart, widget.weekEnd);

    // Convert keys to String for the Chart Widget
    final converted =
        distMap.map((k, v) => MapEntry(k.name.toUpperCase(), v.toDouble()));

    if (mounted) {
      setState(() {
        _distribution = converted;
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
        title: const Text('Muscle Distribution'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent))
          : Padding(
              padding: EdgeInsets.all(GymTheme.spacing.md),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  if (_distribution.isEmpty)
                    Center(
                        child: Text('No workouts this period',
                            style: GymTheme.text.secondary))
                  else
                    Expanded(
                        child: MuscleDistributionChart(
                            distribution: _distribution)),
                ],
              ),
            ),
    );
  }
}
