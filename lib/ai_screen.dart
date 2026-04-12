import 'package:flutter/material.dart';
import 'theme/gym_theme.dart';

/// AI Coach placeholder screen
class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16).copyWith(bottom: 0),
                child: Text(
                  'AI Coach',
                  style: GymTheme.text.displayLg.copyWith(fontSize: 32),
                ),
              ),
            ),
            Expanded(
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
                        color: GymTheme.colors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: GymTheme.colors.accent,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'AI Coach',
                      style: GymTheme.text.headline,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Coming Soon',
                      style: GymTheme.text.body.copyWith(
                        color: GymTheme.colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Get personalized workout recommendations, '
                      'form corrections, and training insights powered by AI.',
                      textAlign: TextAlign.center,
                      style: GymTheme.text.body.copyWith(
                        color: GymTheme.colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48), // Lift it slightly
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
