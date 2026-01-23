import 'package:flutter/material.dart';
import 'profile_header.dart' show ProfileColors;

/// Dashboard tile for profile (Statistics, Exercises, Measures, Calendar)
class ProfileDashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const ProfileDashboardTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ProfileColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ProfileColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: ProfileColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: ProfileColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: ProfileColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 2x2 Dashboard grid for profile
class ProfileDashboard extends StatelessWidget {
  final VoidCallback? onStatisticsTap;
  final VoidCallback? onExercisesTap;
  final VoidCallback? onMeasuresTap;
  final VoidCallback? onCalendarTap;

  const ProfileDashboard({
    super.key,
    this.onStatisticsTap,
    this.onExercisesTap,
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
                  subtitle: 'View progress',
                  onTap: onStatisticsTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProfileDashboardTile(
                  icon: Icons.fitness_center,
                  title: 'Exercises',
                  subtitle: 'Exercise library',
                  onTap: onExercisesTap,
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
                  subtitle: 'Body tracking',
                  onTap: onMeasuresTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProfileDashboardTile(
                  icon: Icons.calendar_today,
                  title: 'Calendar',
                  subtitle: 'Workout history',
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
