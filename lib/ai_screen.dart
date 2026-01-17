import 'package:flutter/material.dart';
import 'main.dart'; // Import AppColors

/// AI Coach placeholder screen
class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'AI Coach',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Get personalized workout recommendations, '
                'form corrections, and training insights powered by AI.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
