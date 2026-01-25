import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../services/workout_history_service.dart';
// import '../services/statistics_service.dart'; // Removed
import '../widgets/week_navigator.dart';
import '../services/muscle_stats_service.dart';
import '../utils/intensity_normalizer.dart';
import '../models/muscle_selector_mapping.dart';
import '../widgets/muscle_heatmap.dart';
import '../widgets/heatmap_intensity_legend.dart';
import '../widgets/distribution_chart.dart';
import '../widgets/main_exercises_list.dart';
import '../widgets/monthly_summary.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  // final StatisticsService _statsService = StatisticsService(); // Removed as filtering is now local
  final MuscleStatsService _muscleStatsService = MuscleStatsService();

  // State
  late DateTime _currentWeekStart;
  bool _loading = true;

  // Data
  List<WorkoutSession> _allSessions = [];
  List<WorkoutSession> _filteredSessions = [];

  // Stats Data
  Map<InternalMuscle, double> _muscleIntensities = {}; // For new Heatmap
  Map<String, double> _muscleDistribution = {}; // For Pie Chart
  List<ExerciseStat> _topExercises = [];
  MonthlyStats? _monthlyStats;

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

    // 3. Adv Stats: Distribution (Convert InternalMuscle -> String Double)
    // Using filtered sessions for current week view
    final distMap =
        _muscleStatsService.computeMuscleDistribution(_allSessions, start, end);
    _muscleDistribution =
        distMap.map((k, v) => MapEntry(k.name.toUpperCase(), v.toDouble()));

    // 4. Adv Stats: Top Exercises
    _topExercises =
        _muscleStatsService.computeMainExercises(_allSessions, start, end);

    // 5. Adv Stats: Monthly Report
    // Uses the Month of the currently viewed week
    _monthlyStats =
        _muscleStatsService.computeMonthlyReport(_allSessions, start);

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
    final now = DateTime.now();
    final currentRealWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    // Determine if we can go next
    final canGoNext = _currentWeekStart.isBefore(currentRealWeekStart);

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
                    // Week Navigator (Replaces PeriodToggle)
                    WeekNavigator(
                      currentWeekStart: _currentWeekStart,
                      canGoNext: canGoNext,
                      onPreviousTap: () => _navigateWeek(-1),
                      onNextTap: () => _navigateWeek(1),
                    ),
                    const SizedBox(height: 32),

                    // HEATMAP (Layout Locked)
                    // Centered and Constrained for all screens

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

                    // --- Advanced Stats Section ---
                    if (_monthlyStats != null &&
                        _filteredSessions.isNotEmpty) ...[
                      const Divider(color: Colors.white10, height: 48),

                      // muscle distribution
                      MuscleDistributionChart(
                          distribution: _muscleDistribution),
                      const SizedBox(height: 24),

                      // top exercises
                      MainExercisesList(exercises: _topExercises),
                      const SizedBox(height: 24),

                      // monthly summary
                      MonthlySummary(
                        workouts: _monthlyStats!.workouts,
                        sets: _monthlyStats!.totalSets,
                        durationMinutes: _monthlyStats!.totalDurationMinutes,
                      ),
                      const SizedBox(height: 32),
                    ] else if (_filteredSessions.isEmpty) ...[
                      const SizedBox(height: 40),
                      const Text("No workouts this week",
                          style: TextStyle(color: Colors.white24)),
                      const SizedBox(height: 40),
                    ],
                    const SizedBox(height: 150), // Reserved space

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }
}
