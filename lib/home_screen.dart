import 'package:flutter/material.dart';
import 'theme/gym_theme.dart';
import 'main.dart';
import 'community_post_sheet.dart';
import 'screens/active_workout_screen.dart';
import 'screens/recent_workout_summary_modal.dart';
import 'services/suggested_workout_service.dart';
import 'services/user_preferences.dart';
import 'services/workout_history_service.dart';
import 'services/settings_service.dart';
import 'dart:io';

/// Sample mock data for Home screen
final Map<String, dynamic> sampleHomeData = {
  "greeting": "Good Morning",
  "userName": "Alex",
  "microContext": "Last workout: Legs • 2 days ago",
  "quickStart": [
    {"title": "Full Body", "icon": Icons.fitness_center},
    {"title": "Cardio", "icon": Icons.directions_run},
    {"title": "Mobility", "icon": Icons.self_improvement},
  ],
  "community": [
    {
      "username": "Sarah M.",
      "workout": "Push Day",
      "exercises": ["Bench Press", "Shoulder Press", "Tricep Dips"],
      "duration": "48 min",
    },
    {
      "username": "Mike R.",
      "workout": "Leg Day",
      "exercises": ["Squats", "Lunges", "Calf Raises"],
      "duration": "55 min",
    },
    {
      "username": "Emma K.",
      "workout": "HIIT Session",
      "exercises": ["Burpees", "Mountain Climbers", "Jump Squats"],
      "duration": "32 min",
    },
  ],
  "recentWorkouts": [
    {"title": "Leg Day", "date": "Yesterday", "duration": "52 min"},
    {"title": "HIIT Session", "date": "2 days ago", "duration": "30 min"},
    {"title": "Core & Abs", "date": "3 days ago", "duration": "25 min"},
  ],
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SuggestedWorkoutService _suggestionService = SuggestedWorkoutService();
  final UserPreferences _userPrefs = UserPreferences();
  final WorkoutHistoryService _historyService = WorkoutHistoryService();

  SuggestedWorkout? _suggestedWorkout;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestion();
  }

  Future<void> _loadSuggestion() async {
    await _userPrefs.init();
    await _historyService.init();
    await SettingsService().init();

    final userLevel = _userPrefs.getExperienceLevelOrDefault();
    final lastRoutineId = _historyService.lastCompletedRoutineId;
    final recentIds = _historyService.getRecentRoutineIds();

    _suggestedWorkout = await _suggestionService.getSuggestedWorkout(
      userLevel: userLevel,
      lastCompletedRoutineId: lastRoutineId,
      recentRoutineIds: recentIds.isNotEmpty ? recentIds : null,
    );

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = sampleHomeData['community'] as List<dynamic>;

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) HEADER / GREETING
              _buildHeader(context),
              const SizedBox(height: 24),

              // 2) PRIMARY ACTION CARD — TODAY'S WORKOUT
              if (_suggestedWorkout != null)
                _buildTodayWorkout(context, _suggestedWorkout!),
              const SizedBox(height: 12),

              // 3) MICRO-CONTEXT STRIP
              _buildMicroContext(context),
              const SizedBox(height: 28),

              // 4) COMMUNITY SECTION
              _buildSectionTitle(context, 'Community'),
              const SizedBox(height: 12),
              _buildCommunity(context, community),
              const SizedBox(height: 28),

              // 5) RECENT WORKOUTS SECTION
              _buildSectionTitle(context, 'Recent Workouts'),
              const SizedBox(height: 12),
              _buildRecentWorkouts(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1) HEADER / GREETING
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, child) {
        final profile = SettingsService().getProfile();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sampleHomeData['greeting']},',
                  style: GymTheme.text.secondary.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.name,
                  style: GymTheme.text.displayLg.copyWith(fontSize: 32),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // Navigate to profile using the bottom nav controller logic preferably,
                // but since we are IN the home tab, tapping profile might switch tabs?
                // For now, let's leave existing behavior or just push profile?
                // The previous code had empty onTap (Navigate to profile commented out).
                // I will maintain the comment or attempt to switch tab if MainShell access exists.
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceLight,
                backgroundImage: profile.avatarPath != null
                    ? FileImage(File(profile.avatarPath!))
                    : null,
                child: profile.avatarPath == null
                    ? const Icon(Icons.person,
                        color: AppColors.textMuted, size: 24)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2) PRIMARY ACTION CARD — TODAY'S WORKOUT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTodayWorkout(BuildContext context, SuggestedWorkout workout) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GymTheme.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Icon(Icons.play_circle_filled,
                  color: GymTheme.colors.accent, size: 18),
              const SizedBox(width: 6),
              const Text(
                "Today's Workout",
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Workout title (largest text)
          Text(
            workout.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Muscle groups
          Text(
            workout.subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActiveWorkoutScreen(
                      routineId: workout.routineId,
                      workoutName: workout.name,
                      preloadedExercises: workout.exercises,
                    ),
                  ),
                );
                // Refresh suggestion after workout
                if (mounted) {
                  _suggestionService.invalidateCache();
                  _loadSuggestion();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Workout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3) MICRO-CONTEXT STRIP
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMicroContext(BuildContext context) {
    return Text(
      sampleHomeData['microContext'] as String,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section Title
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GymTheme.text.sectionTitle,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5) COMMUNITY SECTION
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCommunity(BuildContext context, List<dynamic> posts) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final post = posts[index] as Map<String, dynamic>;
          return _CommunityCard(
            username: post['username'] as String,
            workout: post['workout'] as String,
            exercises: (post['exercises'] as List).cast<String>(),
            duration: post['duration'] as String,
            onTap: () {
              showCommunityPostSheet(
                context,
                CommunityPost(
                  username: post['username'] as String,
                  descriptor: 'Consistent trainer',
                  workout: post['workout'] as String,
                  duration: post['duration'] as String,
                  exercises: (post['exercises'] as List).cast<String>(),
                  totalWorkouts: 124,
                  activityStatus: 'Active this week',
                  preferredSplit: 'Push/Pull/Legs',
                  insight: 'Evening training session',
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 6) RECENT WORKOUTS
  // ─────────────────────────────────────────────────────────────────────────
  /// Build the Recent Workouts section from real history data (grouped)
  Widget _buildRecentWorkouts() {
    final groupedEntries = _historyService.getGroupedRecentWorkouts(limit: 5);

    // Empty state
    if (groupedEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.5)),
        ),
        child: const Center(
          child: Text(
            'No workouts logged yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: groupedEntries
          .map((group) => _buildRecentWorkoutCard(group))
          .toList(),
    );
  }

  /// Format relative date (Today, Yesterday, N days ago)
  String _formatRelativeDate(DateTime completedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedDate =
        DateTime(completedAt.year, completedAt.month, completedAt.day);
    final difference = today.difference(completedDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '$difference days ago';
  }

  /// Build a recent workout card from grouped history entry
  Widget _buildRecentWorkoutCard(GroupedHistoryEntry group) {
    final isFreestyle = group.isFreestyle;
    final durationMinutes = group.totalDuration.inMinutes;

    // Display text with count if grouped
    final nameDisplay =
        group.isGrouped ? '${group.name} ×${group.sessionCount}' : group.name;

    // Subtitle shows aggregate info for grouped
    final subtitle = group.isGrouped
        ? '${group.sessionCount} sessions • $durationMinutes min total'
        : null;

    return GestureDetector(
      onTap: () => RecentWorkoutSummaryModal.show(context, group),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GymTheme.colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color:
                    isFreestyle ? AppColors.surfaceLight : AppColors.accentDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isFreestyle ? Icons.flash_on : Icons.fitness_center,
                color: isFreestyle ? AppColors.textSecondary : AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatRelativeDate(group.date),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (isFreestyle) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Freestyle',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$durationMinutes min',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// Community post card
class _CommunityCard extends StatelessWidget {
  final String username;
  final String workout;
  final List<String> exercises;
  final String duration;
  final VoidCallback? onTap;

  const _CommunityCard({
    required this.username,
    required this.workout,
    required this.exercises,
    required this.duration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User row
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.surface,
                  child: Text(
                    username[0],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    username,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Workout name
            Text(
              workout,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            // Exercises
            Text(
              exercises.take(3).join(' • '),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Bottom row: duration + reactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  duration,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const Row(
                  children: [
                    _ReactionButton(emoji: '🔥'),
                    SizedBox(width: 6),
                    _ReactionButton(emoji: '💪'),
                    SizedBox(width: 6),
                    _ReactionButton(emoji: '👏'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reaction button widget
class _ReactionButton extends StatelessWidget {
  final String emoji;

  const _ReactionButton({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle reaction
      },
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
