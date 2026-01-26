import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';
import '../models/workout_session.dart';
import '../services/workout_history_service.dart';
import '../services/muscle_stats_service.dart';
import '../models/muscle_selector_mapping.dart';
import '../utils/intensity_normalizer.dart';
import '../widgets/week_navigator.dart';
import '../widgets/advanced_stat_row.dart';
import '../widgets/muscle_heatmap.dart';
import '../widgets/heatmap_intensity_legend.dart';
import 'stats/set_count_screen.dart';
import 'stats/muscle_distribution_screen.dart';
import 'stats/main_exercises_screen.dart';
import 'stats/monthly_report_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final MuscleStatsService _muscleStatsService = MuscleStatsService();

  // State
  late DateTime _currentWeekStart;
  bool _loading = true;

  // Data
  List<WorkoutSession> _allSessions = [];
  List<WorkoutSession> _filteredSessions = [];
  Map<InternalMuscle, double> _muscleIntensities = {};

  @override
  void initState() {
    super.initState();
    _initDates();
    _loadData();
  }

  void _initDates() {
    // ISO 8601: Mon=1...Sun=7
    final now = DateTime.now();
    // Monday of current week
    _currentWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  Future<void> _loadData() async {
    // Simulate slight delay for transition
    await Future.delayed(const Duration(milliseconds: 200));

    _allSessions = _historyService.getAllDetailedSessions();

    _updateFilteredData();
  }

  void _updateFilteredData() {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });

    // 1. Filter by Week Range locally (UI Layer only)
    final start = _currentWeekStart;
    final end = _currentWeekStart
        .add(const Duration(days: 7))
        .subtract(const Duration(seconds: 1));

    // Filter sessions strictly within this week (Mon 00:00 to Sun 23:59:59)
    _filteredSessions = _allSessions.where((s) {
      if (s.endTime == null) return false;
      return s.endTime!.isAfter(start) &&
          s.endTime!.isBefore(
              end.add(const Duration(seconds: 1))); // Inclusive safety
    }).toList();

    // 2. Heatmap Data (Normalized)
    final rawMuscleLoad =
        _muscleStatsService.computeMuscleLoad(_filteredSessions);
    _muscleIntensities = IntensityNormalizer.normalize(rawMuscleLoad);

    setState(() {
      _loading = false;
    });
  }

  void _navigateWeek(int offset) {
    final now = DateTime.now();
    final currentRealWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    setState(() {
      final newDate = _currentWeekStart.add(Duration(days: 7 * offset));

      // Future Check
      if (newDate.isAfter(currentRealWeekStart)) {
        return;
      }

      _currentWeekStart = newDate;
    });
    _updateFilteredData();
  }

  void _showMuscleDetails(InternalMuscle muscle) {
    // Light interaction: Show simplified bottom sheet
    final topExercises =
        _muscleStatsService.getTopExercises(muscle, _filteredSessions);
    String muscleName = muscle.name.toUpperCase();
    int totalSets = topExercises.fold(0, (sum, e) => sum + e.value);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                muscleName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$totalSets Sets',
                style: const TextStyle(
                    color: Color(0xFFFC4C02),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              if (topExercises.isEmpty)
                const Text('No data for this period',
                    style: TextStyle(color: Colors.white54)),
              if (topExercises.isNotEmpty) ...[
                const Text(
                  'Top Exercises',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ...topExercises.take(3).map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key,
                              style: const TextStyle(color: Colors.white)),
                          Text('${e.value} sets',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    )),
              ]
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentRealWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    // Determine if we can go next
    final canGoNext = _currentWeekStart.isBefore(currentRealWeekStart);

    final weekEnd = _currentWeekStart
        .add(const Duration(days: 7))
        .subtract(const Duration(seconds: 1));

    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        title: const Text('Statistics'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFC4C02)))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WeekNavigator(
                      currentWeekStart: _currentWeekStart,
                      canGoNext: canGoNext,
                      onPreviousTap: () => _navigateWeek(-1),
                      onNextTap: () => _navigateWeek(1),
                    ),

                    // HEATMAP (Hero Visual)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 400,
                          maxHeight: 450,
                        ),
                        child: MuscleHeatmap(
                          normalizedIntensities: _muscleIntensities,
                          onMuscleTap: _showMuscleDetails,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HeatmapIntensityLegend(),
                        const SizedBox(width: 8),
                        Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 3),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(color: Colors.white),
                          message:
                              "Intensity based on set volume relative to your other muscles.",
                          child: const Icon(Icons.help_outline,
                              color: Colors.white24, size: 18),
                        )
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Advanced Statistics Header
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
                      child: Text(
                        'Advanced statistics',
                        style: GymTheme.text.sectionTitle.copyWith(
                          color: GymTheme.colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List of Navigation Rows
                    AdvancedStatRow(
                      title: 'Set count per muscle group',
                      subtitle: 'Number of sets logged for each muscle group',
                      isPro: true,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SetCountScreen(
                              weekStart: _currentWeekStart, weekEnd: weekEnd),
                        ));
                      },
                    ),
                    AdvancedStatRow(
                      title: 'Muscle distribution (Chart)',
                      subtitle:
                          'Compare your current and previous muscle distributions',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MuscleDistributionScreen(
                              weekStart: _currentWeekStart, weekEnd: weekEnd),
                        ));
                      },
                    ),
                    AdvancedStatRow(
                      title: 'Main exercises',
                      subtitle: 'List of exercises you do most often',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MainExercisesScreen(
                              weekStart: _currentWeekStart, weekEnd: weekEnd),
                        ));
                      },
                    ),
                    AdvancedStatRow(
                      title: 'Monthly Report',
                      subtitle: 'Recap of your monthly workouts and statistics',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MonthlyReportScreen(
                              monthStart: _currentWeekStart),
                        ));
                      },
                    ),
                    AdvancedStatRow(
                      title: 'AI Insights',
                      subtitle: 'Tap to view insights',
                      isPro: true,
                      onTap: () {
                        // Navigate to detail or paywall
                      },
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }
}
