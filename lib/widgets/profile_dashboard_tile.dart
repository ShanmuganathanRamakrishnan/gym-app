import 'package:flutter/material.dart';
import 'profile_header.dart' show ProfileColors;

/// Compact dashboard tile for profile (Statistics, Achievements, Measures, Calendar)
class ProfileDashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ProfileDashboardTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ProfileColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ProfileColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: ProfileColors.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: ProfileColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Achievements tile with "Soon" badge
class _AchievementsTile extends StatelessWidget {
  final VoidCallback? onTap;

  const _AchievementsTile({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ProfileColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ProfileColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: ProfileColors.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Achievements',
                style: TextStyle(
                  color: ProfileColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // "Soon" badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ProfileColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Soon',
                style: TextStyle(
                  color: ProfileColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2x2 Dashboard grid for profile
class ProfileDashboard extends StatelessWidget {
  final VoidCallback? onStatisticsTap;
  final VoidCallback? onAchievementsTap;
  final VoidCallback? onMeasuresTap;
  final VoidCallback? onCalendarTap;

  const ProfileDashboard({
    super.key,
    this.onStatisticsTap,
    this.onAchievementsTap,
    this.onMeasuresTap,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ProfileDashboardTile(
                  icon: Icons.bar_chart,
                  title: 'Statistics',
                  onTap: onStatisticsTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AchievementsTile(
                  onTap: onAchievementsTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ProfileDashboardTile(
                  icon: Icons.straighten,
                  title: 'Measures',
                  onTap: onMeasuresTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProfileDashboardTile(
                  icon: Icons.calendar_today,
                  title: 'Calendar',
                  onTap: onCalendarTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
