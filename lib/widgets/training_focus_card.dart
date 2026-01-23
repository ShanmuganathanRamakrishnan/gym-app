import 'package:flutter/material.dart';
import 'profile_header.dart' show ProfileColors;

/// Training Focus card showing primary muscle group
class TrainingFocusCard extends StatelessWidget {
  final String? primaryMuscle;
  final double? percentage;
  final bool hasEnoughData;

  const TrainingFocusCard({
    super.key,
    this.primaryMuscle,
    this.percentage,
    this.hasEnoughData = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ProfileColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.track_changes,
              color: ProfileColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Training Focus',
                  style: TextStyle(
                    color: ProfileColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasEnoughData && primaryMuscle != null)
                  Row(
                    children: [
                      Text(
                        primaryMuscle!,
                        style: const TextStyle(
                          color: ProfileColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (percentage != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ProfileColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${percentage!.toInt()}%',
                            style: const TextStyle(
                              color: ProfileColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  const Text(
                    'Not enough data',
                    style: TextStyle(
                      color: ProfileColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          // Arrow
          Icon(
            Icons.chevron_right,
            color: ProfileColors.textMuted,
          ),
        ],
      ),
    );
  }
}

/// AI Coach teaser card
class AICoachTeaserCard extends StatelessWidget {
  const AICoachTeaserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ProfileColors.accent.withValues(alpha: 0.2),
            ProfileColors.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ProfileColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ProfileColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Coach',
                  style: TextStyle(
                    color: ProfileColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get personalized workout recommendations',
                  style: TextStyle(
                    color: ProfileColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Coming soon badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ProfileColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Soon',
              style: TextStyle(
                color: ProfileColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
