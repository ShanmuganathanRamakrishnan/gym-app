import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFB3B3B3)),
            onPressed: () {
              // Settings navigation stub
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFC4C02),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFFFC4C02),
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compact header with avatar and inline stats
                    ProfileHeader(
                      username: 'Athlete',
                      workoutCount: _aggregates?.stats.totalWorkouts ?? 0,
                      currentStreak: _aggregates?.streaks.currentStreak ?? 0,
                      totalHours: (_aggregates?.stats.totalMinutes ?? 0) ~/ 60,
                      onSocialTap: _openFollowersModal,
                    ),

                    const SizedBox(height: 12),

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
