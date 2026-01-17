import 'package:flutter/material.dart';

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
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFFC4C02),
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
        return const Color(0xFFFC4C02);
      case WorkoutCardVariant.inProgress:
        return const Color(0xFFFFA726);
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
        padding: const EdgeInsets.all(20),
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
                  style: TextStyle(
                    color: _accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (progress > 0) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% complete',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCtaPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  ctaLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon,
              color: const Color(0xFFFC4C02),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A0A0A),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFC4C02).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFFFC4C02),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF6B6B6B),
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
      backgroundColor: const Color(0xFF1A1A1A), // Dark surface
      selectedItemColor: const Color(0xFFFC4C02), // Strava orange
      unselectedItemColor: const Color(0xFFB3B3B3), // textSecondary
      showUnselectedLabels: true,
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
