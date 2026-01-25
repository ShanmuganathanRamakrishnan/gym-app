import 'package:flutter/material.dart';

// Profile theme colors
class ProfileColors {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color accent = Color(0xFFFC4C02);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF757575);
}

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar (56px)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ProfileColors.surfaceLight,
              border: Border.all(
                color: ProfileColors.accent.withValues(alpha: 0.5),
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
          const SizedBox(width: 12),

          // Username & secondary info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    color: ProfileColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _buildSecondaryText(),
                  style: const TextStyle(
                    color: ProfileColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Social icon button
          IconButton(
            onPressed: onSocialTap,
            icon: const Icon(
              Icons.people_outline,
              color: ProfileColors.textSecondary,
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
    return const Icon(
      Icons.person,
      size: 28,
      color: ProfileColors.textMuted,
    );
  }
}
