import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';
import '../services/profile_repository.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_dashboard_tile.dart';
import '../widgets/profile_progress_graph.dart';
import '../widgets/followers_modal.dart';
import 'statistics_screen.dart';
import 'measurements_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

/// Profile Screen - Hevy-inspired compact profile view
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();
  ProfileAggregates? _aggregates;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final aggregates = await _repository.getProfileAggregates();
      if (mounted) {
        setState(() {
          _aggregates = aggregates;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aggregates = ProfileAggregates.empty();
          _loading = false;
        });
      }
    }
  }

  void _openFollowersModal() {
    FollowersModal.show(context, followers: 0, following: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: GymTheme.colors.accent,
              ),
            )
          : RefreshIndicator(
              color: GymTheme.colors.accent,
              onRefresh: _loadProfile,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Scroll-aware Header
                  SliverAppBar(
                    backgroundColor: GymTheme.colors.background,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    pinned: false,
                    floating: false,
                    snap: false,
                    title: Text(
                      'Profile',
                      style: GymTheme.text.screenTitle,
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.settings,
                            color: GymTheme.colors.textSecondary),
                        onPressed: () {
                          // Nested navigation within Profile tab
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // 2. Main Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Compact header with avatar and inline stats
                          ProfileHeader(
                            username: 'Athlete',
                            workoutCount: _aggregates?.stats.totalWorkouts ?? 0,
                            currentStreak:
                                _aggregates?.streaks.currentStreak ?? 0,
                            totalHours:
                                (_aggregates?.stats.totalMinutes ?? 0) ~/ 60,
                            onSocialTap: _openFollowersModal,
                          ),

                          const SizedBox(height: 24),

                          // Graph constrained to max 180px or screen percentage (handled by SizedBox)
                          // Using simplified Week graph logic for Sprint B next
                          SizedBox(
                            height: 180,
                            child: ProfileProgressGraph(
                              recentWorkouts: _aggregates?.recentWorkouts ?? [],
                            ),
                          ),

                          // Sprint C: Compact Summary Row removed per user request
                          const SizedBox(height: 16),

                          // Dashboard tiles (Navigation) - PRESERVED
                          ProfileDashboard(
                            onStatisticsTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const StatisticsScreen(),
                                ),
                              );
                            },
                            onAchievementsTap: () {
                              // Placeholder
                            },
                            onMeasuresTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MeasurementsScreen(),
                                ),
                              );
                            },
                            onCalendarTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CalendarScreen(),
                                ),
                              );
                            },
                          ),

                          // Safe Bottom Padding (Nav bar + SafeArea)
                          SizedBox(
                              height: MediaQuery.of(context).padding.bottom +
                                  kBottomNavigationBarHeight +
                                  24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Removed _buildMetricsGrid as per Sprint A instructions
  // Removed _buildMetricTile as per Sprint A instructions
}
