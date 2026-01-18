import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'main.dart';
import 'services/user_preferences.dart';
import 'screens/experience_onboarding_screen.dart';

/// Auth / Onboarding screen with carousel and login/signup forms
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  void _toggleAuthMode() {
    setState(() => _showLogin = !_showLogin);
  }

  Future<void> _handleAuthSuccess() async {
    // Check if onboarding is completed
    final prefs = UserPreferences();
    await prefs.init();

    if (!prefs.onboardingCompleted) {
      // Show onboarding
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ExperienceOnboardingScreen()),
        );
      }
    } else {
      // Navigate directly to home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Onboarding Carousel
              const OnboardingCarousel(),

              const SizedBox(height: 24),

              // Auth Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Auth Form
                    AuthForm(
                      isLogin: _showLogin,
                      onSuccess: _handleAuthSuccess,
                    ),

                    const SizedBox(height: 20),

                    // Toggle Login/Signup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleAuthMode,
                          child: Text(
                            _showLogin ? 'Sign up' : 'Sign in',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.divider)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Social Buttons
                    const Row(
                      children: [
                        Expanded(
                          child: SocialButton(
                            provider: 'google',
                            label: 'Google',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: SocialButton(
                            provider: 'apple',
                            label: 'Apple',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
