import 'package:flutter/material.dart';

class ProInsightsCard extends StatelessWidget {
  final VoidCallback onUnlockTap;
  final bool isPro;

  const ProInsightsCard({
    super.key,
    required this.onUnlockTap,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUnlockTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFC4C02).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFC4C02).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: Color(0xFFFC4C02), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'AI Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // PRO Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC4C02),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('PRO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.lock_outline, color: Colors.white54, size: 18),
              ],
            ),
            const SizedBox(height: 12),

            // Content List
            _buildFeatureItem("Muscle imbalance detection"),
            _buildFeatureItem("Training recommendations"),
            _buildFeatureItem("Monthly & yearly insights analysis"),

            const SizedBox(height: 16),

            // CTA
            Center(
              child: Text(
                "Tap to Unlock",
                style: TextStyle(
                  color: const Color(0xFFFC4C02).withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: Colors.white24, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
