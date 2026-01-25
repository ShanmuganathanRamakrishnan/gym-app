import 'package:flutter/material.dart';
import '../main.dart';
import '../data/prebuilt_routines.dart';
import '../services/user_preferences.dart';

/// Post-auth onboarding screen to collect user experience level
class ExperienceOnboardingScreen extends StatefulWidget {
  const ExperienceOnboardingScreen({super.key});

  @override
  State<ExperienceOnboardingScreen> createState() =>
      _ExperienceOnboardingScreenState();
}

class _ExperienceOnboardingScreenState
    extends State<ExperienceOnboardingScreen> {
  ExperienceLevel? _selectedLevel;
  bool _saving = false;

  Future<void> _continue() async {
    if (_selectedLevel == null || _saving) return;

    setState(() => _saving = true);

    final prefs = UserPreferences();
    await prefs.setExperienceLevel(_selectedLevel!);
    await prefs.completeOnboarding();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              const Text(
                'Tell us your experience level',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'This helps us suggest the right workouts for you.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Experience Level Cards
              _buildLevelCard(
                level: ExperienceLevel.beginner,
                title: 'Beginner',
                description: 'New to lifting or returning after a long break',
              ),
              const SizedBox(height: 16),

              _buildLevelCard(
                level: ExperienceLevel.intermediate,
                title: 'Intermediate',
                description: 'Training consistently for 6–18 months',
              ),
              const SizedBox(height: 16),

              _buildLevelCard(
                level: ExperienceLevel.advanced,
                title: 'Advanced',
                description: 'Training consistently for 2+ years',
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _selectedLevel != null && !_saving ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceLight,
                    disabledForegroundColor: AppColors.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required ExperienceLevel level,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedLevel == level;

    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x33FC4C02),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          isSelected ? AppColors.accent : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.surfaceLight, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
