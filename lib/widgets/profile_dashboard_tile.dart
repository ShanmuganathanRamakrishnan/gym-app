import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

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
        padding:
            EdgeInsets.symmetric(horizontal: GymTheme.spacing.md, vertical: 10),
        decoration: BoxDecoration(
          color: GymTheme.colors.surface,
          borderRadius: BorderRadius.circular(GymTheme.radius.card),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: GymTheme.colors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(GymTheme.radius.sm),
              ),
              child: Icon(
                icon,
                color: GymTheme.colors.accent,
                size: 18,
              ),
            ),
            SizedBox(width: GymTheme.spacing.sm),
            Text(
              title,
              style: GymTheme.text.cardTitle.copyWith(fontSize: 13),
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
        padding:
            EdgeInsets.symmetric(horizontal: GymTheme.spacing.md, vertical: 10),
        decoration: BoxDecoration(
          color: GymTheme.colors.surface,
          borderRadius: BorderRadius.circular(GymTheme.radius.card),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: GymTheme.colors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(GymTheme.radius.sm),
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                color: GymTheme.colors.accent,
                size: 18,
              ),
            ),
            SizedBox(width: GymTheme.spacing.sm),
            Expanded(
              child: Text(
                'Achievements',
                style: GymTheme.text.cardTitle.copyWith(fontSize: 13),
              ),
            ),
            // "Soon" badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: GymTheme.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Soon',
                style: GymTheme.text.secondary
                    .copyWith(fontSize: 9, fontWeight: FontWeight.w600),
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
      // Padding handled by parent generally, but enforcing horizontal here if needed
      padding: EdgeInsets.zero,
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
              SizedBox(width: GymTheme.spacing.md),
              Expanded(
                child: _AchievementsTile(
                  onTap: onAchievementsTap,
                ),
              ),
            ],
          ),
          SizedBox(height: GymTheme.spacing.md),
          Row(
            children: [
              Expanded(
                child: ProfileDashboardTile(
                  icon: Icons.straighten,
                  title: 'Measures',
                  onTap: onMeasuresTap,
                ),
              ),
              SizedBox(width: GymTheme.spacing.md),
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
