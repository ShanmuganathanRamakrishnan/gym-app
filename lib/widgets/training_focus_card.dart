import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

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
      margin: EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
      padding: EdgeInsets.all(GymTheme.spacing.md),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.card),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: GymTheme.colors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.track_changes,
              color: GymTheme.colors.accent,
              size: 24,
            ),
          ),
          SizedBox(width: GymTheme.spacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Focus',
                  style: GymTheme.text.secondary
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: GymTheme.spacing.xs),
                if (hasEnoughData && primaryMuscle != null)
                  Row(
                    children: [
                      Text(
                        primaryMuscle!,
                        style: GymTheme.text.cardTitle,
                      ),
                      if (percentage != null) ...[
                        SizedBox(width: GymTheme.spacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                GymTheme.colors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${percentage!.toInt()}%',
                            style: TextStyle(
                              color: GymTheme.colors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Text(
                    'Not enough data',
                    style: GymTheme.text.body,
                  ),
              ],
            ),
          ),

          // Arrow
          Icon(
            Icons.chevron_right,
            color: GymTheme.colors.textMuted,
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
      margin: EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
      padding: EdgeInsets.all(GymTheme.spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GymTheme.colors.accent.withValues(alpha: 0.2), // 0x33 ~ 0.2
            GymTheme.colors.accent.withValues(alpha: 0.05), // 0x0D ~ 0.05
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(GymTheme.radius.card),
        border: Border.all(
          color: GymTheme.colors.accent.withValues(alpha: 0.3),
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
              color: GymTheme.colors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: GymTheme.spacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Coach',
                  style: GymTheme.text.cardTitle,
                ),
                SizedBox(height: GymTheme.spacing.xs),
                Text(
                  'Get personalized workout recommendations',
                  style: GymTheme.text.secondary,
                ),
              ],
            ),
          ),

          // Coming soon badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: GymTheme.colors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Soon',
              style: TextStyle(
                color: GymTheme.colors.textMuted,
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
