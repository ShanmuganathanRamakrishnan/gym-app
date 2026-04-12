import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator
import 'theme/gym_theme.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'ai_screen.dart';

import 'workout_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const GymApp());
}

/// Dark mode color constants (Bridge to GymTheme)
class AppColors {
  // Hardcoded mirroring GymTheme values to preserve const support globally
  static const background = Color(0xFF0E0E0E);
  static const surface = Color(0xFF20201F);
  static const surfaceLight = Color(0xFF262626);
  static const divider = Color(0xFF131313);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textMuted = Color(0xFFADAAAA);
  static const accent = Color(0xFFFF8F6F);
  static const accentDim = Color(0xFFFF734A);
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      debugShowCheckedModeBanner: false,
      theme: GymTheme.themeData,
      // Start at Auth screen
      home: const AuthScreen(),
    );
  }
}

/// Main navigation shell with bottom nav
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // GlobalKeys for nested navigators to control history per tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    // Hevy-style persistent navigation: root Scaffold + nested Navigators per tab
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1. Try to pop nested navigator
        final navigator = _navigatorKeys[_selectedIndex].currentState;
        if (navigator == null) return;

        if (navigator.canPop()) {
          navigator.pop();
        } else if (_selectedIndex != 0) {
          // 2. If at root of non-Home tab, switch to Home
          setState(() => _selectedIndex = 0);
        } else {
          // 3. If at Home root, exit app (Android only)
          if (Theme.of(context).platform == TargetPlatform.android) {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildNavigator(_navigatorKeys[0], const HomeScreen()),
            _buildNavigator(_navigatorKeys[1], const WorkoutScreen()),
            _buildNavigator(_navigatorKeys[2], const AIScreen()),
            _buildNavigator(_navigatorKeys[3], const ProfileScreen()),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (_selectedIndex == index) {
              // If tapping active tab, pop to root
              _navigatorKeys[index]
                  .currentState
                  ?.popUntil((route) => route.isFirst);
            } else {
              setState(() => _selectedIndex = index);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black, // Persistent nav must be solid black
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build a nested navigator for each tab
  Widget _buildNavigator(GlobalKey<NavigatorState> key, Widget child) {
    return Navigator(
      key: key,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => child,
        );
      },
    );
  }
}

/// Legacy WorkoutsScreen placeholder - now using WorkoutScreen from workout_screen.dart
/// ProfileScreen is now imported from screens/profile_screen.dart
