import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../services/workout_history_service.dart';
import '../services/statistics_service.dart';
import '../widgets/period_toggle.dart';
import '../widgets/muscle_heatmap.dart';

import '../services/muscle_stats_service.dart';
import '../utils/intensity_normalizer.dart';
import '../models/muscle_selector_mapping.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final StatisticsService _statsService = StatisticsService();
  final MuscleStatsService _muscleStatsService = MuscleStatsService();

  // State
  TimeWindow _selectedWindow = TimeWindow.thisWeek;
  bool _loading = true;

  // Data
  List<WorkoutSession> _allSessions = [];
  List<WorkoutSession> _filteredSessions = [];

  // Stats Data
  Map<InternalMuscle, double> _muscleIntensities = {}; // For new Heatmap

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate slight delay for transition
    await Future.delayed(const Duration(milliseconds: 200));

    _allSessions = _historyService.getAllDetailedSessions();

    // Monthly calc removed for layout lock phase
    // _calculateMonthlyData();

    _updateFilteredData();
  }

  /* Monthly Data logic commented out for layout lock
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
  */

  void _updateFilteredData() {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });

    // 1. Current Window Data
    _filteredSessions =
        _statsService.filterSessions(_allSessions, _selectedWindow);

    // Old Stats Service logic removed for layout lock
    // final muscleStats = _statsService.aggregateMuscleSets(_filteredSessions);
    // _muscleDistribution = muscleStats.setsPerMuscle;
    // _workouts = _filteredSessions.length;
    // _sets = muscleStats.totalSets;
    // _duration =_filteredSessions.fold(0, (sum, s) => sum + s.totalDuration.inMinutes);

    // New Muscle Stats (for Heatmap)
    final rawMuscleLoad =
        _muscleStatsService.computeMuscleLoad(_filteredSessions);
    _muscleIntensities = IntensityNormalizer.normalize(rawMuscleLoad);

    // 2. Previous Window Data removed for layout lock
    /*
    if (_selectedWindow == TimeWindow.thisWeek) {
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
    */

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

  void _showMuscleDetails(InternalMuscle muscle) {
    // 1. Get stats
    final topExercises =
        _muscleStatsService.getTopExercises(muscle, _filteredSessions);
    // Convert generic muscle name
    String muscleName = muscle.name.toUpperCase();

    // Calculate total sets for this muscle (from raw load calculation logic essentially)
    // We can re-compute or just sum top exercises?
    // Compound logic makes exact "set count" tricky to display if we distributed values (decimals).
    // Let's count "Direct Sets" involving this muscle?
    // Or just sum the exercise set counts (which might double count if exercise hits multiple)?
    // User wants "Total sets".
    // _muscleStatsService.computeMuscleLoad returns doubles.
    // Let's re-calculate precise value or just sum the truncated counts for display.
    // Normalized intensity is stored, but raw load isn't stored in state (oops, local var).
    // I will just sum the top exercises values for the display (approximate matches what user sees in list).
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
                // Show top 3
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
          : SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Period Toggle
                    PeriodToggle(
                      selectedWindow: _selectedWindow,
                      onWindowChanged: _onWindowChanged,
                    ),
                    const SizedBox(height: 32),

                    // HEATMAP (Layout Locked)
                    // Centered and Constrained for all screens
                    const Text('Muscle Heatmap',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth:
                              400, // Prevent massive heatmap on huge screens
                          maxHeight: 500, // Explicit height cap safety
                        ),
                        child: MuscleHeatmap(
                          normalizedIntensities: _muscleIntensities,
                          onMuscleTap: _showMuscleDetails,
                        ),
                      ),
                    ),

                    // SPACE FOR LEGEND
                    const SizedBox(height: 24),
                    // TODO: Insert HeatmapLegend here

                    const Divider(color: Colors.white12),
                    const SizedBox(height: 24),

                    // SPACE FOR DISTRIBUTION
                    // TODO: Insert MuscleDistributionChart here
                    const SizedBox(height: 200), // Reserved space

                    const Divider(color: Colors.white12),
                    const SizedBox(height: 24),

                    // SPACE FOR WEEKLY BARS
                    // TODO: Insert WeeklySummaryBars here
                    const SizedBox(height: 150), // Reserved space

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }
}
