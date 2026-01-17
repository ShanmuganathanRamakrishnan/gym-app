import 'package:flutter/material.dart';

/// AI Coach placeholder screen
class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  // Light theme colors matching design-spec.json
  static const accent = Color(0xFF00C2A8);
  static const accentDim = Color(0x3300C2A8);
  static const textPrimary = Color(0xFF0A0A0A);
  static const textSecondary = Color(0xFF6B6B6B);

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
                  color: accentDim,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: accent,
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
                  color: accent,
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
