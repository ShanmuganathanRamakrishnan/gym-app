// Home screen - main dashboard with today's workout and quick actions
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/workout_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),

              // Today's Workout
              const WorkoutCard(
                title: 'Upper Body Strength',
                subtitle: 'Chest · Shoulders · Triceps',
                duration: '45 min',
                exercises: 8,
                progress: 0.0,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick Start
              Text('Quick Start',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _buildQuickStart(context),
              const SizedBox(height: AppSpacing.lg),

              // Recent
              Text('Recent', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _buildRecentList(context),
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
            Text('Good Evening', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text('Alex', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.surfaceAlt,
          child: Icon(Icons.person, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildQuickStart(BuildContext context) {
    return const Row(
      children: [
        Expanded(
            child: _QuickCard(icon: Icons.fitness_center, label: 'Full Body')),
        SizedBox(width: AppSpacing.sm),
        Expanded(
            child: _QuickCard(icon: Icons.directions_run, label: 'Cardio')),
        SizedBox(width: AppSpacing.sm),
        Expanded(
            child: _QuickCard(icon: Icons.self_improvement, label: 'Stretch')),
      ],
    );
  }

  Widget _buildRecentList(BuildContext context) {
    return const Column(
      children: [
        _RecentItem(title: 'Leg Day', date: 'Yesterday', duration: '52 min'),
        _RecentItem(
            title: 'HIIT Session', date: '2 days ago', duration: '30 min'),
        _RecentItem(
            title: 'Core & Abs', date: '3 days ago', duration: '25 min'),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 26),
          const SizedBox(height: AppSpacing.xs),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  final String title;
  final String date;
  final String duration;

  const _RecentItem(
      {required this.title, required this.date, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.fitness_center,
                color: AppColors.textMuted, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(date,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(duration,
              style: const TextStyle(color: AppColors.textSecondary)),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
