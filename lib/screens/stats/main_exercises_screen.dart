import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/workout_history_service.dart';
import '../../services/muscle_stats_service.dart';
import '../../widgets/main_exercises_list.dart';

class MainExercisesScreen extends StatefulWidget {
  final DateTime weekStart;
  final DateTime weekEnd;

  const MainExercisesScreen({
    super.key,
    required this.weekStart,
    required this.weekEnd,
  });

  @override
  State<MainExercisesScreen> createState() => _MainExercisesScreenState();
}

class _MainExercisesScreenState extends State<MainExercisesScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final MuscleStatsService _muscleStatsService = MuscleStatsService();

  bool _loading = true;
  List<ExerciseStat> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allSessions = _historyService.getAllDetailedSessions();

    final exercises = _muscleStatsService.computeMainExercises(
        allSessions, widget.weekStart, widget.weekEnd);

    if (mounted) {
      setState(() {
        _exercises = exercises;
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
        title: const Text('Main Exercises'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent))
          : SingleChildScrollView(
              padding: EdgeInsets.all(GymTheme.spacing.md),
              child: MainExercisesList(exercises: _exercises),
            ),
    );
  }
}
