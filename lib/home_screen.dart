import 'package:flutter/material.dart';
import 'main.dart';
import 'widgets.dart';

/// Sample mock data for Home screen
final Map<String, dynamic> sampleHomeData = {
  "greeting": "Good Evening",
  "userName": "Alex",
  "todayWorkout": {
    "title": "Upper Body Strength",
    "subtitle": "Chest · Shoulders · Triceps",
    "progress": 0.0,
    "duration": "45 min",
    "exercises": 8,
  },
  "quickStart": [
    {"title": "Full Body", "icon": Icons.fitness_center},
    {"title": "Cardio", "icon": Icons.directions_run},
    {"title": "Stretch", "icon": Icons.self_improvement},
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
    final recent = sampleHomeData['recentWorkouts'] as List<dynamic>;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 20),

              // Today's Workout Hero
              _buildTodayWorkout(context, workout),
              const SizedBox(height: 24),

              // Quick Start
              _buildSectionTitle(context, 'Quick Start'),
              const SizedBox(height: 12),
              _buildQuickStart(context, quickStart),
              const SizedBox(height: 24),

              // Recent Workouts
              _buildSectionTitle(context, 'Recent'),
              const SizedBox(height: 12),
              ...recent.map(
                  (w) => _buildRecentItem(context, w as Map<String, dynamic>)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sampleHomeData['greeting'] as String,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 2),
            Text(
              sampleHomeData['userName'] as String,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.surfaceLight,
          child: const Icon(Icons.person, color: AppColors.textMuted, size: 22),
        ),
      ],
    );
  }

  Widget _buildTodayWorkout(
      BuildContext context, Map<String, dynamic> workout) {
    final progress = (workout['progress'] as num).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "TODAY'S WORKOUT",
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (progress > 0)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            workout['title'] as String,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            workout['subtitle'] as String,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Meta row
          Row(
            children: [
              _buildMeta(Icons.timer_outlined, workout['duration'] as String),
              const SizedBox(width: 16),
              _buildMeta(Icons.format_list_numbered,
                  '${workout['exercises']} exercises'),
            ],
          ),
          const SizedBox(height: 16),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Start Workout',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildQuickStart(BuildContext context, List<dynamic> items) {
    return Row(
      children: items.map((item) {
        final data = item as Map<String, dynamic>;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: item != items.last ? 10 : 0),
            child: _QuickStartCard(
              title: data['title'] as String,
              icon: data['icon'] as IconData,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentItem(BuildContext context, Map<String, dynamic> workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center,
                color: AppColors.textMuted, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  workout['date'] as String,
                  style:
                      const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            workout['duration'] as String,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

/// Quick Start card widget
class _QuickStartCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _QuickStartCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceLight, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 26),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
