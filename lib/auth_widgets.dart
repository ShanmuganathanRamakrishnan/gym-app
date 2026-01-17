import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';

// ============================================================================
// Onboarding Carousel
// ============================================================================

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;

  final List<Map<String, String>> _slides = const [
    {
      'title': 'Track workouts',
      'subtitle': 'Log sets, reps and progress easily.',
    },
    {
      'title': 'Build routines',
      'subtitle': 'Save and reuse your favorite splits.',
    },
    {
      'title': 'Improve over time',
      'subtitle': 'Small, consistent wins add up.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (_controller.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              // Reset timer on manual swipe
              _autoAdvanceTimer?.cancel();
              _startAutoAdvance();
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return OnboardingSlide(
                title: slide['title']!,
                subtitle: slide['subtitle']!,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.accent
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.accentDim,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: AppColors.accent,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Auth Form Widget
// ============================================================================

class AuthFormWidget extends StatefulWidget {
  final bool isLogin;
  final VoidCallback onSuccess;

  const AuthFormWidget({
    super.key,
    required this.isLogin,
    required this.onSuccess,
  });

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (!widget.isLogin && (value == null || value.isEmpty)) {
      return 'Name is required';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate auth delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name field (signup only)
          if (!widget.isLogin) ...[
            TextFormField(
              controller: _nameController,
              validator: _validateName,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email field
          TextFormField(
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            validator: _validatePassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : Text(widget.isLogin ? 'Log In' : 'Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Social Button
// ============================================================================

class SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.textPrimary),
      label: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
