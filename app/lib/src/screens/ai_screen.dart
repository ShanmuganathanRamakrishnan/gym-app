// AI Coach placeholder screen
import 'package:flutter/material.dart';
import '../theme.dart';

class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Coach')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppColors.accent, size: 40),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('AI Coach',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              const Text('Coming Soon',
                  style: TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Get personalized workout recommendations, form corrections, and training insights powered by AI.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null, // Disabled
                  child: const Text('Tell me my goals'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
