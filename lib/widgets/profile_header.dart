import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

/// Compact profile header with avatar, username, and secondary info
class ProfileHeader extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final int workoutCount;
  final int currentStreak;
  final int totalHours;
  final VoidCallback? onSocialTap;

  const ProfileHeader({
    super.key,
    required this.username,
    this.avatarUrl,
    this.workoutCount = 0,
    this.currentStreak = 0,
    this.totalHours = 0,
    this.onSocialTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GymTheme.spacing.md, // 16 -> md (16)
        vertical: GymTheme.spacing.md, // 12 -> md (16) for consistency?
      ),
      // Removed 16px hardcode, using theme spacing
      child: Row(
        children: [
          // Avatar (56px)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GymTheme.colors.surfaceElevated,
              border: Border.all(
                color: GymTheme.colors.accent.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
          SizedBox(width: GymTheme.spacing.md),

          // Username & secondary info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GymTheme.text.sectionTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  _buildSecondaryText(),
                  style: GymTheme.text.secondary,
                ),
              ],
            ),
          ),

          // Social icon button
          IconButton(
            onPressed: onSocialTap,
            icon: Icon(
              Icons.people_outline,
              color: GymTheme.colors.textSecondary,
              size: 22,
            ),
            tooltip: 'Followers & Following',
          ),
        ],
      ),
    );
  }

  String _buildSecondaryText() {
    final parts = <String>[];
    parts.add('$workoutCount workouts');
    if (currentStreak > 0) {
      parts.add('$currentStreak-day streak');
    } else if (totalHours > 0) {
      parts.add('${totalHours}h total');
    }
    return parts.join(' • ');
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 28,
      color: GymTheme.colors.textMuted,
    );
  }
}
