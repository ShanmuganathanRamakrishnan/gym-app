import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

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
      backgroundColor: GymTheme.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(GymTheme.radius.xl)),
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
      padding: EdgeInsets.all(GymTheme.spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: GymTheme.colors.surfaceElevated,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: GymTheme.spacing.lg),

          // Title
          Text(
            'Social',
            style: GymTheme.text.sectionTitle,
          ),
          SizedBox(height: GymTheme.spacing.lg),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Followers', followerCount),
              Container(
                width: 1,
                height: 40,
                color: GymTheme.colors.surfaceElevated,
              ),
              _buildStatColumn('Following', followingCount),
            ],
          ),
          SizedBox(height: GymTheme.spacing.lg),

          // Coming soon message
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: GymTheme.spacing.md, vertical: 12),
            decoration: BoxDecoration(
              color: GymTheme.colors.surfaceElevated,
              borderRadius: BorderRadius.circular(GymTheme.radius.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: GymTheme.colors.textMuted,
                  size: 18,
                ),
                SizedBox(width: GymTheme.spacing.md),
                Expanded(
                  child: Text(
                    'Social features coming soon',
                    style: GymTheme.text.secondary.copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: GymTheme.spacing.md),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GymTheme.text.headline,
        ),
        SizedBox(height: GymTheme.spacing.xs),
        Text(
          label,
          style: GymTheme.text.secondary,
        ),
      ],
    );
  }
}
