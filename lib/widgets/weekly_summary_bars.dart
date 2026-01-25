import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../services/statistics_service.dart';

class WeeklySummaryBars extends StatefulWidget {
  final List<WorkoutSession> sessions;
  final TimeWindow window;

  const WeeklySummaryBars({
    super.key,
    required this.sessions,
    required this.window,
  });

  @override
  State<WeeklySummaryBars> createState() => _WeeklySummaryBarsState();
}

class _WeeklySummaryBarsState extends State<WeeklySummaryBars> {
  BarMetric _selectedMetric = BarMetric.sets;
  final StatisticsService _service = StatisticsService();

  @override
  Widget build(BuildContext context) {
    // 1. Aggregate Data
    final bars = _service.aggregateWeeklyBars(
        widget.sessions, widget.window, _selectedMetric);

    // Find max value for scaling
    final maxValue = bars.fold(0.0, (max, b) => b.value > max ? b.value : max);
    final displayMax = maxValue == 0 ? 10.0 : maxValue * 1.2; // Add headroom

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Metric Selection
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Current Metric Insight (Simple Total for now)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getInsightText(bars),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.window == TimeWindow.thisWeek
                      ? "This Week"
                      : "Last Week",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            // Toggle
            _buildMetricToggle(),
          ],
        ),
        const SizedBox(height: 24),

        // Bar Chart
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: bars.map((bar) {
              final heightPct = (bar.value / displayMax).clamp(0.0, 1.0);
              final isToday = _isToday(bar.date);

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Value Label (optional, maybe only for non-zero)
                    if (bar.value > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          _formatValue(bar.value),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    // Bar
                    Container(
                      height: 100 * heightPct, // Max bar height 100
                      width: 12, // Fixed width bars
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFFFC4C02)
                            : (bar.value > 0
                                ? const Color(0xFFFC4C02).withValues(alpha: 0.6)
                                : const Color(0xFF2C2C2E)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Day Label
                    Text(
                      bar.dayLabel, // M, T, W...
                      style: TextStyle(
                        color:
                            isToday ? const Color(0xFFFC4C02) : Colors.white54,
                        fontSize: 12,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(BarMetric.sets, 'Sets'),
          _toggleBtn(BarMetric.volume, 'Vol'),
          _toggleBtn(BarMetric.reps, 'Reps'),
          _toggleBtn(BarMetric.duration, 'Time'),
        ],
      ),
    );
  }

  Widget _toggleBtn(BarMetric metric, String label) {
    final isSelected = _selectedMetric == metric;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = metric;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3A3A3C)
              : Colors.transparent, // Subtle highlight
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _getInsightText(List<WeeklyBarData> bars) {
    final total = bars.fold(0.0, (sum, b) => sum + b.value);
    switch (_selectedMetric) {
      case BarMetric.sets:
        return '${total.toInt()} Sets';
      case BarMetric.volume:
        return '${_formatValue(total)} kg';
      case BarMetric.reps:
        return '${total.toInt()} Reps';
      case BarMetric.duration:
        return '${total.toInt()} mins';
    }
  }

  String _formatValue(double val) {
    if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}k';
    }
    if (val % 1 == 0) return val.toInt().toString();
    return val.toStringAsFixed(1);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
