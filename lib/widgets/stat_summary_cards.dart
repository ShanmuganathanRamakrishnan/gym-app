import 'package:flutter/material.dart';

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
        const SizedBox(width: 8),
        Expanded(child: _buildCard('Sets', sets, prevSets, isCount: true)),
        const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 2, top: 4),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
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
