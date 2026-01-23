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

/// Profile header with avatar, username, and quick stats
class ProfileHeader extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final int workoutCount;
  final int followerCount;
  final int followingCount;

  const ProfileHeader({
    super.key,
    required this.username,
    this.avatarUrl,
    this.workoutCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ProfileColors.surfaceLight,
              border: Border.all(
                color: ProfileColors.accent.withValues(alpha: 0.5),
                width: 2,
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
          const SizedBox(height: 12),

          // Username
          Text(
            username,
            style: const TextStyle(
              color: ProfileColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('Workouts', workoutCount),
              _buildDivider(),
              _buildStatItem('Followers', followerCount),
              _buildDivider(),
              _buildStatItem('Following', followingCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 36,
      color: ProfileColors.textMuted,
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              color: ProfileColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: ProfileColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: ProfileColors.surfaceLight,
    );
  }
}
