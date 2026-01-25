import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/workout_history_service.dart';
import '../../services/muscle_stats_service.dart';
import '../../models/muscle_selector_mapping.dart';
import '../../utils/intensity_normalizer.dart';
import '../../widgets/muscle_heatmap.dart';
import '../../widgets/heatmap_intensity_legend.dart';

class MuscleHeatmapScreen extends StatefulWidget {
  final DateTime weekStart;
  final DateTime weekEnd;

  const MuscleHeatmapScreen({
    super.key,
    required this.weekStart,
    required this.weekEnd,
  });

  @override
  State<MuscleHeatmapScreen> createState() => _MuscleHeatmapScreenState();
}

class _MuscleHeatmapScreenState extends State<MuscleHeatmapScreen> {
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  final MuscleStatsService _muscleStatsService = MuscleStatsService();

  bool _loading = true;
  Map<InternalMuscle, double> _normalizedIntensities = {};
  List<dynamic> _filteredSessions = []; // Keep for detail popup logic

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allSessions = _historyService.getAllDetailedSessions();

    // Filter locally
    final filtered = allSessions.where((s) {
      if (s.endTime == null) return false;
      return s.endTime!.isAfter(widget.weekStart) &&
          s.endTime!.isBefore(widget.weekEnd);
    }).toList();

    final rawLoad = _muscleStatsService.computeMuscleLoad(filtered);
    final normalized = IntensityNormalizer.normalize(rawLoad);

    if (mounted) {
      setState(() {
        _filteredSessions = filtered;
        _normalizedIntensities = normalized;
        _loading = false;
      });
    }
  }

  void _showMuscleDetails(InternalMuscle muscle) {
    // Re-using logic from old StatisticsScreen
    // Ideally duplicate strictly necessary parts or move logic to service
    final topExercises = _muscleStatsService.getTopExercises(muscle,
        _filteredSessions as dynamic); // Cast if needed, but list is covariant

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
                muscle.name.toUpperCase(),
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
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        title: const Text('Body Heatmap'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent))
          : Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 500,
                      ),
                      child: MuscleHeatmap(
                        normalizedIntensities: _normalizedIntensities,
                        onMuscleTap: _showMuscleDetails,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const HeatmapIntensityLegend(),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
