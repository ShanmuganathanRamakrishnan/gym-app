// App routing configuration using go_router
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav.dart';

/// Route paths
class AppRoutes {
  static const auth = '/auth';
  static const home = '/';
  static const workouts = '/workouts';
  static const ai = '/ai';
  static const profile = '/profile';
}

/// Shell route key for bottom navigation
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.auth,
  routes: [
    // Auth screen (no bottom nav)
    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) => const AuthScreen(),
    ),

    // Main app with bottom navigation shell
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.workouts,
          builder: (context, state) => const WorkoutScreen(),
        ),
        GoRoute(
          path: AppRoutes.ai,
          builder: (context, state) => const AIScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

/// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.workouts)) return 1;
    if (location.startsWith(AppRoutes.ai)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _getSelectedIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.workouts);
              break;
            case 2:
              context.go(AppRoutes.ai);
              break;
            case 3:
              context.go(AppRoutes.profile);
              break;
          }
        },
      ),
    );
  }
}
