import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/gym_theme.dart';

// ============================================================================
// AppBar Component
// ============================================================================

class GymAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? avatarUrl;

  const GymAppBar({
    super.key,
    required this.title,
    this.avatarUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: GymTheme.text.screenTitle),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: GymTheme.colors.accent,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 20)
                : null,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// WorkoutCard Component
// ============================================================================

enum WorkoutCardVariant { notStarted, inProgress, completed }

class WorkoutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final String ctaLabel;
  final WorkoutCardVariant variant;
  final VoidCallback? onCtaPressed;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.ctaLabel,
    this.variant = WorkoutCardVariant.notStarted,
    this.onCtaPressed,
  });

  Color get _accentColor {
    switch (variant) {
      case WorkoutCardVariant.notStarted:
        return GymTheme.colors.accent;
      case WorkoutCardVariant.inProgress:
        return GymTheme.colors.accentContainer;
      case WorkoutCardVariant.completed:
        return const Color(0xFF4CAF50);
    }
  }

  IconData get _statusIcon {
    switch (variant) {
      case WorkoutCardVariant.notStarted:
        return Icons.play_circle_fill;
      case WorkoutCardVariant.inProgress:
        return Icons.pause_circle_filled;
      case WorkoutCardVariant.completed:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24), // Tonal Layering: 1.5rem padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_statusIcon, color: _accentColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  variant == WorkoutCardVariant.completed
                      ? 'Completed'
                      : variant == WorkoutCardVariant.inProgress
                          ? 'In Progress'
                          : "Today's Workout",
                  style: GymTheme.text.secondary.copyWith(
                    color: _accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GymTheme.text.headline,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GymTheme.text.body,
            ),
            if (progress > 0) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: GymTheme.colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% complete',
                style: GymTheme.text.secondary,
              ),
            ],
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [GymTheme.colors.accentDim, GymTheme.colors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(GymTheme.radius.button),
              ),
              child: ElevatedButton(
                onPressed: onCtaPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black, // on_primary_fixed
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GymTheme.radius.button),
                  ),
                ),
                child: Text(
                  ctaLabel,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TemplateCard Component
// ============================================================================

class TemplateCard extends StatelessWidget {
  final String title;
  final String iconName;
  final VoidCallback? onTap;

  const TemplateCard({
    super.key,
    required this.title,
    required this.iconName,
    this.onTap,
  });

  IconData get _icon {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'directions_run':
        return Icons.directions_run;
      case 'self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.sports_gymnastics;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: GymTheme.colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(GymTheme.radius.card),
          // Removed opaque shadows
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon,
              color: GymTheme.colors.accent,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GymTheme.text.secondary.copyWith(
                fontWeight: FontWeight.w600,
                color: GymTheme.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// RecentRow Component
// ============================================================================

class RecentRow extends StatelessWidget {
  final String title;
  final String date;
  final String detail;

  const RecentRow({
    super.key,
    required this.title,
    required this.date,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GymTheme.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: GymTheme.colors.accentDim.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fitness_center,
              color: GymTheme.colors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GymTheme.text.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: GymTheme.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GymTheme.text.secondary,
                ),
              ],
            ),
          ),
          Text(
            detail,
            style: GymTheme.text.body,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: GymTheme.colors.textMuted,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BottomNav Component
// ============================================================================

class GymBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const GymBottomNav({
    super.key,
    required this.selectedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black, // "Solid Black" background required by design
      selectedItemColor: GymTheme.colors.accent,
      unselectedItemColor: GymTheme.colors.textSecondary,
      showUnselectedLabels: true,
      selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center_outlined),
          activeIcon: Icon(Icons.fitness_center),
          label: 'Workouts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_outlined),
          activeIcon: Icon(Icons.auto_awesome),
          label: 'AI',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
