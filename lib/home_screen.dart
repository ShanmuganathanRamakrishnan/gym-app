import 'package:flutter/material.dart';
import 'main.dart';
import 'community_post_sheet.dart';
import 'screens/active_workout_screen.dart';

/// Sample mock data for Home screen
final Map<String, dynamic> sampleHomeData = {
  "greeting": "Good Morning",
  "userName": "Alex",
  "todayWorkout": {
    "title": "Upper Body Strength",
    "subtitle": "Chest · Shoulders · Triceps",
  },
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = sampleHomeData['todayWorkout'] as Map<String, dynamic>;
    final quickStart = sampleHomeData['quickStart'] as List<dynamic>;
    final community = sampleHomeData['community'] as List<dynamic>;
    final recent = sampleHomeData['recentWorkouts'] as List<dynamic>;

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
              _buildTodayWorkout(context, workout),
              const SizedBox(height: 12),

              // 3) MICRO-CONTEXT STRIP
              _buildMicroContext(context),
              const SizedBox(height: 28),

              // 4) QUICK START SECTION
              _buildSectionTitle(context, 'Quick Start'),
              const SizedBox(height: 12),
              _buildQuickStart(context, quickStart),
              const SizedBox(height: 28),

              // 5) COMMUNITY SECTION
              _buildSectionTitle(context, 'Community'),
              const SizedBox(height: 12),
              _buildCommunity(context, community),
              const SizedBox(height: 28),

              // 6) RECENT WORKOUTS SECTION
              _buildSectionTitle(context, 'Recent Workouts'),
              const SizedBox(height: 12),
              ...recent.map(
                  (w) => _buildRecentItem(context, w as Map<String, dynamic>)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sampleHomeData['greeting']},',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sampleHomeData['userName'] as String,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // Navigate to profile
          },
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceLight,
            child: Icon(Icons.person, color: AppColors.textMuted, size: 24),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2) PRIMARY ACTION CARD — TODAY'S WORKOUT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTodayWorkout(
      BuildContext context, Map<String, dynamic> workout) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          const Row(
            children: [
              Icon(Icons.play_circle_filled, color: AppColors.accent, size: 18),
              SizedBox(width: 6),
              Text(
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
            workout['title'] as String,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Muscle groups
          Text(
            workout['subtitle'] as String,
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActiveWorkoutScreen(
                      workoutName: workout['title'] as String,
                    ),
                  ),
                );
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
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4) QUICK START SECTION
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildQuickStart(BuildContext context, List<dynamic> items) {
    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value as Map<String, dynamic>;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 5,
              right: index == items.length - 1 ? 0 : 5,
            ),
            child: _QuickStartCard(
              title: data['title'] as String,
              icon: data['icon'] as IconData,
            ),
          ),
        );
      }).toList(),
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
  Widget _buildRecentItem(BuildContext context, Map<String, dynamic> workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center,
                color: AppColors.textMuted, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  workout['date'] as String,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            workout['duration'] as String,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// Quick Start card widget
class _QuickStartCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _QuickStartCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Quick start action
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceLight, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
