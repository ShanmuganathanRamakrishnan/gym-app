import 'package:flutter/material.dart';
import 'profile_header.dart' show ProfileColors;

/// Followers/Following modal bottom sheet
class FollowersModal extends StatelessWidget {
  final int followerCount;
  final int followingCount;

  const FollowersModal({
    super.key,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  static void show(BuildContext context,
      {int followers = 0, int following = 0}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ProfileColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FollowersModal(
        followerCount: followers,
        followingCount: following,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ProfileColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Social',
            style: TextStyle(
              color: ProfileColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Followers', followerCount),
              Container(
                width: 1,
                height: 40,
                color: ProfileColors.surfaceLight,
              ),
              _buildStatColumn('Following', followingCount),
            ],
          ),
          const SizedBox(height: 24),

          // Coming soon message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ProfileColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: ProfileColors.textMuted,
                  size: 18,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Social features coming soon',
                    style: TextStyle(
                      color: ProfileColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: ProfileColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: ProfileColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
