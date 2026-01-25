import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';
import '../widgets/week_navigator.dart';
import '../widgets/advanced_stat_row.dart';
import '../widgets/pro_insights_card.dart';
import 'stats/set_count_screen.dart';
import 'stats/muscle_distribution_screen.dart';
import 'stats/muscle_heatmap_screen.dart';
import 'stats/main_exercises_screen.dart';
import 'stats/monthly_report_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // State
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _initDates();
  }

  void _initDates() {
    // ISO 8601: Mon=1...Sun=7
    final now = DateTime.now();
    // Monday of current week
    _currentWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: GymTheme.spacing.md,
                    vertical: GymTheme.spacing.md),
                child: WeekNavigator(
                  currentWeekStart: _currentWeekStart,
                  canGoNext: canGoNext,
                  onPreviousTap: () => _navigateWeek(-1),
                  onNextTap: () => _navigateWeek(1),
                ),
              ),

              const SizedBox(height: 16),

              // Advanced Statistics Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
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
                title: 'Muscle distribution (Body)',
                subtitle: 'Weekly heat map of muscles worked',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MuscleHeatmapScreen(
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
                    builder: (_) =>
                        MonthlyReportScreen(monthStart: _currentWeekStart),
                  ));
                },
              ),

              const SizedBox(height: 32),

              // PRO AI Insights Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
                child: ProInsightsCard(
                  onUnlockTap: () {
                    // Navigate to paywall
                  },
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
