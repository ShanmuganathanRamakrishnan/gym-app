// WorkoutCard widget - hero card for today's workout
import 'package:flutter/material.dart';
import '../theme.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final int exercises;
  final double progress;
  final VoidCallback? onStart;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.exercises,
    this.progress = 0.0,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                      letterSpacing: 0.5),
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
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),

          // Meta
          Row(
            children: [
              _Meta(icon: Icons.timer_outlined, text: duration),
              const SizedBox(width: AppSpacing.md),
              _Meta(
                  icon: Icons.format_list_numbered,
                  text: '$exercises exercises'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              child: const Text('Start Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }
}
