import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../services/workout_history_service.dart';
import '../services/statistics_service.dart';
import '../widgets/period_toggle.dart';
import '../widgets/muscle_heatmap.dart';
import '../widgets/heatmap_legend.dart';
import '../widgets/distribution_chart.dart';
import '../widgets/weekly_summary_bars.dart';
import '../widgets/stat_summary_cards.dart';
import '../widgets/monthly_summary.dart';
import 'statistics_advanced_placeholder.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final StatisticsService _statsService = StatisticsService();

  // State
  TimeWindow _selectedWindow = TimeWindow.thisWeek;
  bool _loading = true;

  // Data
  List<WorkoutSession> _allSessions = [];
  List<WorkoutSession> _filteredSessions = [];
  Map<String, double> _muscleSetsHeatmap = {};
  Map<String, double> _muscleDistribution = {};

  // Summary Data
  int _workouts = 0;
  int _sets = 0;
  int _duration = 0;

  // Previous Period Data (for comparison)
  int? _prevWorkouts;
  int? _prevSets;
  int? _prevDuration;

  // Monthly Data
  int _monthlyWorkouts = 0;
  int _monthlySets = 0;
  int _monthlyDuration = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate slight delay for transition
    await Future.delayed(const Duration(milliseconds: 200));

    _allSessions = _historyService.getAllDetailedSessions();

    // Quick monthly calc (independent of toggle)
    _calculateMonthlyData();

    _updateFilteredData();
  }

  void _calculateMonthlyData() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final monthlySessions = _allSessions.where((s) {
      if (s.endTime == null) return false;
      return s.endTime!.isAtSameMomentAs(startOfMonth) ||
          s.endTime!.isAfter(startOfMonth);
    }).toList();

    _monthlyWorkouts = monthlySessions.length;
    _monthlySets =
        monthlySessions.fold(0, (sum, s) => sum + s.totalSetsCompleted);
    _monthlyDuration =
        monthlySessions.fold(0, (sum, s) => sum + s.totalDuration.inMinutes);
  }

  void _updateFilteredData() {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });

    // 1. Current Window Data
    _filteredSessions =
        _statsService.filterSessions(_allSessions, _selectedWindow);

    final muscleStats = _statsService.aggregateMuscleSets(_filteredSessions);
    _muscleSetsHeatmap = muscleStats.setsPerMuscle;
    _muscleDistribution =
        muscleStats.setsPerMuscle; // Use same data for distribution

    _workouts = _filteredSessions.length;
    _sets = muscleStats.totalSets;
    _duration =
        _filteredSessions.fold(0, (sum, s) => sum + s.totalDuration.inMinutes);

    // 2. Previous Window Data (for deltas)
    // 2. Previous Window Data (for deltas)

    // However, the Enum has 'LastWeek' which acts as previous for 'ThisWeek'.
    // For 'LastWeek', we need '2 Weeks Ago'. My Service doesn't support that yet.
    // I will enable simple comparison:
    // ThisWeek -> compare with LastWeek
    // LastWeek -> compare with (Previous 7 days? Not supported by enum) -> pass null
    // Last4Weeks -> compare with (Prior 4 Weeks? Not supported) -> pass null

    // Improvement: StatisticsService should support custom dates, but sticking to Enum for now.
    // Only 'This Week' can strictly compare with 'Last Week' easily via Enum behavior.

    if (_selectedWindow == TimeWindow.thisWeek) {
      // Actually I need to re-call filter with TimeWindow.lastWeek
      final lastWeekSessions =
          _statsService.filterSessions(_allSessions, TimeWindow.lastWeek);
      final prevStatsData = _statsService.aggregateMuscleSets(lastWeekSessions);

      _prevWorkouts = lastWeekSessions.length;
      _prevSets = prevStatsData.totalSets;
      _prevDuration = lastWeekSessions.fold<int>(
          0, (int sum, s) => sum + s.totalDuration.inMinutes);
    } else {
      _prevWorkouts = null;
      _prevSets = null;
      _prevDuration = null;
    }

    setState(() {
      _loading = false;
    });
  }

  void _onWindowChanged(TimeWindow window) {
    setState(() {
      _selectedWindow = window;
    });
    _updateFilteredData();
  }

  void _showMuscleValue(String muscle, double count) {
    // Show modal as requested
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
                muscle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${count.toInt()} Sets',
                style: const TextStyle(
                    color: Color(0xFFFC4C02),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              // Placeholder for "Top Exercises"
              const Text(
                'Top Exercises',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 12),
              // We could compute top exercises here, but for MVP just showing the count is fine.
              const Text('Bench Press (Sample)',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Hevy is very dark/black
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Statistics', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFC4C02)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Toggle
                  PeriodToggle(
                    selectedWindow: _selectedWindow,
                    onWindowChanged: _onWindowChanged,
                  ),
                  const SizedBox(height: 24),

                  // HEATMAP
                  const Text('Muscle Heatmap',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  MuscleHeatmap(
                    muscleSets: _muscleSetsHeatmap,
                    onMuscleTap: _showMuscleValue,
                  ),
                  const SizedBox(height: 12),
                  const HeatmapLegend(),

                  const SizedBox(height: 32),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 24),

                  // DISTRIBUTION
                  const Text('Distribution',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  MuscleDistributionChart(distribution: _muscleDistribution),

                  const SizedBox(height: 32),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 24),

                  // WEEKLY BARS (Last 7 Days Body Graph)
                  const Text('Last 7 days',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight
                              .bold)), // Changed title to match screenshot-ish
                  const SizedBox(height: 16),
                  WeeklySummaryBars(
                    sessions: _filteredSessions,
                    window: _selectedWindow, // Bars widget handles logic
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 24),

                  // SUMMARY CARDS
                  StatSummaryCards(
                    workouts: _workouts,
                    sets: _sets,
                    durationMinutes: _duration,
                    prevWorkouts: _prevWorkouts,
                    prevSets: _prevSets,
                    prevDuration: _prevDuration,
                  ),

                  const SizedBox(height: 32),

                  // MONTHLY SUMMARY
                  MonthlySummary(
                    workouts: _monthlyWorkouts,
                    sets: _monthlySets,
                    durationMinutes: _monthlyDuration,
                  ),

                  const SizedBox(height: 32),

                  // ADVANCED STATS (PRO)
                  const StatisticsAdvancedPlaceholder(),

                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }
}
