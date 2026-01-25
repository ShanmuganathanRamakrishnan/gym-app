import 'package:flutter/material.dart';
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
  static const background = Color(0xFF0E0E0E); // GymTheme.colors.background
  static const surface = Color(0xFF1E1E1E);
  static const surfaceLight = Color(0xFF2C2C2E);
  static const divider = Color(0xFF2A2A2A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textMuted = Color(0xFF6B6B6B);
  static const accent = Color(0xFFFC4C02);
  static const accentDim = Color(0x33FC4C02);
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

  final List<Widget> _screens = const [
    HomeScreen(),
    WorkoutScreen(),
    AIScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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
    );
  }
}

/// Legacy WorkoutsScreen placeholder - now using WorkoutScreen from workout_screen.dart
/// ProfileScreen is now imported from screens/profile_screen.dart
