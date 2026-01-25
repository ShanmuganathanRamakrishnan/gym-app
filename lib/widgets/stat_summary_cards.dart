import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

class StatSummaryCards extends StatelessWidget {
  final int workouts;
  final int sets;
  final int durationMinutes;

  final int? prevWorkouts;
  final int? prevSets;
  final int? prevDuration;

  const StatSummaryCards({
    super.key,
    required this.workouts,
    required this.sets,
    required this.durationMinutes,
    this.prevWorkouts,
    this.prevSets,
    this.prevDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child:
                _buildCard('Workouts', workouts, prevWorkouts, isCount: true)),
        SizedBox(width: GymTheme.spacing.md),
        Expanded(child: _buildCard('Sets', sets, prevSets, isCount: true)),
        SizedBox(width: GymTheme.spacing.md),
        Expanded(
            child: _buildCard('Duration', durationMinutes, prevDuration,
                unit: 'm', isCount: false)),
      ],
    );
  }

  Widget _buildCard(String title, int value, int? prev,
      {String? unit, required bool isCount}) {
    double? deltaPct;
    if (prev != null && prev != 0) {
      deltaPct = (value - prev) / prev;
    }

    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 12, horizontal: GymTheme.spacing.sm),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.card),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: GymTheme.text.headline.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 2, top: 4),
                  child: Text(
                    unit,
                    style: GymTheme.text.secondary.copyWith(fontSize: 12),
                  ),
                ),
            ],
          ),
          SizedBox(height: GymTheme.spacing.xs),
          Text(
            title,
            style: GymTheme.text.secondary.copyWith(fontSize: 10),
          ),
          if (deltaPct != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildDelta(deltaPct),
            ),
        ],
      ),
    );
  }

  Widget _buildDelta(double pct) {
    final isPositive = pct >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 16),
        Text(
          '${(pct.abs() * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
