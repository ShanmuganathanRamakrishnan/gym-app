import 'package:flutter/material.dart';

class HeatmapIntensityLegend extends StatelessWidget {
  const HeatmapIntensityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem("Low", 0.3),
          const SizedBox(width: 16),
          const Text("•", style: TextStyle(color: Colors.white24)),
          const SizedBox(width: 16),
          _buildLegendItem("Medium", 0.6),
          const SizedBox(width: 16),
          const Text("•", style: TextStyle(color: Colors.white24)),
          const SizedBox(width: 16),
          _buildLegendItem("High", 1.0),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double intensity) {
    // Matches logic in muscle_heatmap.dart
    final color = const Color(0xFFFC4C02).withValues(alpha: intensity);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
