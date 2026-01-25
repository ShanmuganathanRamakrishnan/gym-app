import 'package:flutter/material.dart';
import '../services/statistics_service.dart';

class PeriodToggle extends StatelessWidget {
  final TimeWindow selectedWindow;
  final ValueChanged<TimeWindow> onWindowChanged;

  const PeriodToggle({
    super.key,
    required this.selectedWindow,
    required this.onWindowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // Darker gray bg for toggle group
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TimeWindow.values.map((window) {
          final isSelected = selectedWindow == window;
          return Expanded(
            // Or Flexible if not expanded
            child: GestureDetector(
              onTap: () => onWindowChanged(window),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFFC4C02) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getLabel(window),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(TimeWindow window) {
    switch (window) {
      case TimeWindow.thisWeek:
        return 'This Week';
      case TimeWindow.lastWeek:
        return 'Last Week';
      case TimeWindow.last4Weeks:
        return 'Last 4 Weeks';
    }
  }
}
