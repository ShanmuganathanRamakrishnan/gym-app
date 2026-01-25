import 'package:flutter/material.dart';

class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Low',
            style: TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                Colors.grey.withValues(alpha: 0.1),
                const Color(0xFFFC4C02).withValues(alpha: 0.3),
                const Color(0xFFFC4C02).withValues(alpha: 0.5),
                const Color(0xFFFC4C02).withValues(alpha: 0.8),
                const Color(0xFFFC4C02),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text('High',
            style: TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}
