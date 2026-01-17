// Auth screen with onboarding carousel and login/signup forms
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../routes.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;

  void _toggleMode() => setState(() => _isLogin = !_isLogin);

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const _OnboardingCarousel(),
              const SizedBox(height: AppSpacing.xl),
              _AuthForm(
                isLogin: _isLogin,
                isLoading: _isLoading,
                onSubmit: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              _ToggleButton(isLogin: _isLogin, onToggle: _toggleMode),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCarousel extends StatefulWidget {
  const _OnboardingCarousel();

  @override
  State<_OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<_OnboardingCarousel> {
  final _controller = PageController();
  int _page = 0;
  Timer? _timer;

  final _slides = [
    {
      'title': 'Track workouts',
      'subtitle': 'Log sets, reps and progress easily.'
    },
    {
      'title': 'Build routines',
      'subtitle': 'Save and reuse your favorite splits.'
    },
    {
      'title': 'Improve over time',
      'subtitle': 'Small, consistent wins add up.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!mounted) return;
      final next = (_page + 1) % _slides.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
            onPageChanged: (p) {
              setState(() => _page = p);
              _startTimer();
            },
            itemCount: _slides.length,
            itemBuilder: (_, i) => _Slide(
              title: _slides[i]['title']!,
              subtitle: _slides[i]['subtitle']!,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _DotsIndicator(count: _slides.length, current: _page),
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Slide({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.accentDim,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(Icons.fitness_center,
              color: AppColors.accent, size: 40),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          count,
          (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == current ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == current ? AppColors.accent : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
    );
  }
}

class _AuthForm extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _AuthForm(
      {required this.isLogin, required this.isLoading, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isLogin) ...[
          const TextField(
              decoration: InputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: AppSpacing.md),
        ],
        const TextField(
            decoration: InputDecoration(
                hintText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: AppSpacing.md),
        const TextField(
            decoration: InputDecoration(
                hintText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
            obscureText: true),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(isLogin ? 'Sign in' : 'Create account'),
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggle;

  const _ToggleButton({required this.isLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "Don't have an account? " : "Already have an account? ",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            isLogin ? 'Sign up' : 'Sign in',
            style: const TextStyle(
                color: AppColors.accent, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
