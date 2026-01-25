import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/workout_history_service.dart';
import '../../services/muscle_stats_service.dart';
import '../../models/muscle_selector_mapping.dart';
import '../../widgets/charts/muscle_radar_chart.dart';

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
  Map<String, double> _radarData = {};

  // For normalization
  static const double _minThreshold = 10.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allSessions = _historyService.getAllDetailedSessions();

    // 1. Get Distribution (Set counts per InternalMuscle)
    // The service returns Map<InternalMuscle, int>
    final distMap = _muscleStatsService.computeMuscleDistribution(
        allSessions, widget.weekStart, widget.weekEnd);

    // 2. Map InternalMuscle to the 8 Fixed Radar Axes
    // Axes: CHEST, SHOULDERS, ARMS, CORE, QUADS, HAMSTRINGS, GLUTES, BACK
    final Map<String, double> aggregated = {
      'CHEST': 0,
      'SHOULDERS': 0,
      'ARMS': 0,
      'CORE': 0,
      'QUADS': 0,
      'HAMSTRINGS': 0,
      'GLUTES': 0,
      'BACK': 0,
    };

    distMap.forEach((muscle, sets) {
      final val = sets.toDouble();
      switch (muscle) {
        case InternalMuscle.chest:
          aggregated['CHEST'] = (aggregated['CHEST'] ?? 0) + val;
          break;
        case InternalMuscle.shoulders: // neck sometimes groups here
        case InternalMuscle.neck:
          aggregated['SHOULDERS'] = (aggregated['SHOULDERS'] ?? 0) + val;
          break;
        case InternalMuscle.biceps:
        case InternalMuscle.triceps:
        case InternalMuscle.forearms:
          aggregated['ARMS'] = (aggregated['ARMS'] ?? 0) + val;
          break;
        case InternalMuscle.abs:
          aggregated['CORE'] = (aggregated['CORE'] ?? 0) + val;
          break;
        case InternalMuscle.quads:
        case InternalMuscle.adductors: // front leg ish
          aggregated['QUADS'] = (aggregated['QUADS'] ?? 0) + val;
          break;
        case InternalMuscle.hamstrings:
          aggregated['HAMSTRINGS'] = (aggregated['HAMSTRINGS'] ?? 0) + val;
          break;
        case InternalMuscle.glutes:
        case InternalMuscle.abductors: // hips/glutes
          aggregated['GLUTES'] = (aggregated['GLUTES'] ?? 0) + val;
          break;
        case InternalMuscle.back:
        case InternalMuscle.traps:
          aggregated['BACK'] = (aggregated['BACK'] ?? 0) + val;
          break;
        case InternalMuscle
            .calves: // Often omitted or merged. Hevy merges legs or separates?
          // Hevy radar has specific axes. Let's map Calves to HAMSTRINGS or QUADS or exclude?
          // Let's add to HAMSTRINGS for posterior chain bucket if needed, or ignore.
          // User list didn't include Calves. Let's put in HAMSTRINGS (Back Leg) for now.
          aggregated['HAMSTRINGS'] = (aggregated['HAMSTRINGS'] ?? 0) + val;
          break;
        default:
          // cardio etc.
          break;
      }
    });

    // 3. Normalize
    // Find max value
    double maxVal = 0;
    aggregated.forEach((_, v) {
      if (v > maxVal) maxVal = v;
    });

    // Denom: max(maxVal, 10.0)
    final denom = max(maxVal, _minThreshold);

    final normalized = aggregated.map((k, v) {
      return MapEntry(k, (v / denom).clamp(0.0, 1.0));
    });

    if (mounted) {
      setState(() {
        _radarData = normalized;
        _loading = false;
      });
    }
  }

  void _showInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Muscle Balance',
                  style: GymTheme.text.headline.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'This chart visualizes your training balance across major muscle groups.\n\n'
              '• A larger, rounder shape indicates a well-balanced routine.\n'
              '• Spikes visualizes focus on specific areas.\n\n'
              'Values are relative to your highest volume muscle group.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        title: Row(
          children: [
            const Text('Muscle Distribution'),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showInfo,
              child:
                  Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent))
          : Padding(
              padding: EdgeInsets.all(GymTheme.spacing.md),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Render Radar
                  Expanded(
                    child: Center(
                      child: _radarData.isEmpty
                          ? Text('No data', style: GymTheme.text.secondary)
                          : MuscleRadarChart(normalizedData: _radarData),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Optional footer or empty space
                  if (_radarData.values.every((v) => v == 0))
                    Text(
                      'No workouts logged for this period',
                      style: GymTheme.text.secondary,
                    ),
                ],
              ),
            ),
    );
  }
}
