import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';
import '../services/profile_repository.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_dashboard_tile.dart';
import '../widgets/profile_progress_graph.dart';
import '../widgets/training_focus_card.dart' show AICoachTeaserCard;
import '../widgets/followers_modal.dart';
import 'statistics_screen.dart';

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
      appBar: AppBar(
        backgroundColor: GymTheme.colors
            .surface, // Profile has varied header color in original? Keeping surface for consistency or background?
        // Original was 1E1E1E (surface) while scaffolding was 121212.
        // Let's align with GymTheme.
        elevation: 0,
        title: Text(
          'Profile',
          style: GymTheme.text.screenTitle,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: GymTheme.colors.textSecondary),
            onPressed: () {
              // Settings navigation stub
            },
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: GymTheme.colors.accent,
              ),
            )
          : RefreshIndicator(
              color: GymTheme.colors.accent,
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                    horizontal: GymTheme.spacing.md), // Add padding for content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: GymTheme.spacing.md),
                    // Compact header with avatar and inline stats
                    ProfileHeader(
                      username: 'Athlete',
                      workoutCount: _aggregates?.stats.totalWorkouts ?? 0,
                      currentStreak: _aggregates?.streaks.currentStreak ?? 0,
                      totalHours: (_aggregates?.stats.totalMinutes ?? 0) ~/ 60,
                      onSocialTap: _openFollowersModal,
                    ),

                    SizedBox(height: GymTheme.spacing.md),

                    // Progress graph with Volume/Reps/Duration toggle
                    ProfileProgressGraph(
                      recentWorkouts: _aggregates?.recentWorkouts ?? [],
                    ),

                    const SizedBox(height: 16),

                    // Dashboard tiles (2x2)
                    ProfileDashboard(
                      onStatisticsTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        );
                      },
                      onAchievementsTap: () {
                        // Placeholder - Achievements coming soon
                      },
                      onMeasuresTap: () {
                        // Navigation stub
                      },
                      onCalendarTap: () {
                        // Navigation stub
                      },
                    ),

                    const SizedBox(height: 16),

                    // AI Coach teaser (secondary visual weight)
                    const AICoachTeaserCard(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
