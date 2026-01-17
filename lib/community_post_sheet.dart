import 'package:flutter/material.dart';
import 'main.dart';

/// Data model for community post
class CommunityPost {
  final String username;
  final String descriptor;
  final String workout;
  final String duration;
  final List<String> exercises;
  final int totalWorkouts;
  final String activityStatus;
  final String preferredSplit;
  final String? insight;
  final Set<String> userReactions;

  const CommunityPost({
    required this.username,
    required this.descriptor,
    required this.workout,
    required this.duration,
    required this.exercises,
    required this.totalWorkouts,
    required this.activityStatus,
    required this.preferredSplit,
    this.insight,
    this.userReactions = const {},
  });
}

/// Shows the community post user context bottom sheet
void showCommunityPostSheet(BuildContext context, CommunityPost post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CommunityPostSheet(post: post),
  );
}

class _CommunityPostSheet extends StatefulWidget {
  final CommunityPost post;

  const _CommunityPostSheet({required this.post});

  @override
  State<_CommunityPostSheet> createState() => _CommunityPostSheetState();
}

class _CommunityPostSheetState extends State<_CommunityPostSheet> {
  late Set<String> _activeReactions;

  @override
  void initState() {
    super.initState();
    _activeReactions = Set.from(widget.post.userReactions);
  }

  void _toggleReaction(String emoji) {
    setState(() {
      if (_activeReactions.contains(emoji)) {
        _activeReactions.remove(emoji);
      } else {
        _activeReactions.add(emoji);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // 1) USER SNAPSHOT
                      _buildUserSnapshot(),
                      const SizedBox(height: 20),

                      // 2) LATEST WORKOUT SUMMARY
                      _buildWorkoutCard(),
                      const SizedBox(height: 20),

                      // 3) REACTIONS
                      _buildReactions(),
                      const SizedBox(height: 16),

                      // 4) MICRO-INSIGHT
                      if (widget.post.insight != null) _buildMicroInsight(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1) USER SNAPSHOT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUserSnapshot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User identity row
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surface,
              child: Text(
                widget.post.username[0],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.username,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.post.descriptor,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Stats row (max 3)
        Row(
          children: [
            _buildStatItem('${widget.post.totalWorkouts} workouts'),
            _buildStatDivider(),
            _buildStatItem(widget.post.activityStatus),
            _buildStatDivider(),
            _buildStatItem(widget.post.preferredSplit),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String text) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 12,
      color: AppColors.surfaceLight,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2) WORKOUT CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWorkoutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout title
          Text(
            widget.post.workout,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Duration
          Text(
            widget.post.duration,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Photo placeholder
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                color: AppColors.textMuted,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Exercise list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: widget.post.exercises.length > 6
                  ? 6
                  : widget.post.exercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildExerciseItem(
                    widget.post.exercises[index], index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(String exercise, int number) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            exercise,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3) REACTIONS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildReactions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildReactionButton('🔥'),
        const SizedBox(width: 16),
        _buildReactionButton('💪'),
        const SizedBox(width: 16),
        _buildReactionButton('👏'),
      ],
    );
  }

  Widget _buildReactionButton(String emoji) {
    final isActive = _activeReactions.contains(emoji);

    return GestureDetector(
      onTap: () => _toggleReaction(emoji),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentDim : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.surfaceLight,
            width: 1.5,
          ),
        ),
        child: AnimatedScale(
          scale: isActive ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4) MICRO-INSIGHT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMicroInsight() {
    return Center(
      child: Text(
        widget.post.insight!,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
        ),
      ),
    );
  }
}
