import 'package:flutter/material.dart';
import '../services/profile_repository.dart';
import '../services/workout_history_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_dashboard_tile.dart';
import '../widgets/training_focus_card.dart';

/// Profile Screen - Hevy-inspired read-only profile view
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();
  ProfileAggregates? _aggregates;
  bool _loading = true;
  int _selectedChipIndex = 0;

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
                    // Header with avatar and stats
                    ProfileHeader(
                      username: 'Athlete',
                      workoutCount: _aggregates?.stats.totalWorkouts ?? 0,
                      followerCount: 0,
                      followingCount: 0,
                    ),

                    const SizedBox(height: 16),

                    // Summary stats card
                    ProfileStatsRow(
                      totalMinutes: _aggregates?.stats.totalMinutes ?? 0,
                      totalSets: _aggregates?.stats.totalSets ?? 0,
                      totalReps: 0, // Not tracked yet
                      selectedIndex: _selectedChipIndex,
                      onChipSelected: (index) {
                        setState(() => _selectedChipIndex = index);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Dashboard tiles (2x2)
                    ProfileDashboard(
                      onStatisticsTap: () {
                        // Navigation stub
                      },
                      onExercisesTap: () {
                        // Navigation stub
                      },
                      onMeasuresTap: () {
                        // Navigation stub
                      },
                      onCalendarTap: () {
                        // Navigation stub
                      },
                    ),

                    const SizedBox(height: 24),

                    // Recent Workouts section
                    _buildRecentWorkoutsSection(),

                    const SizedBox(height: 24),

                    // Training Focus
                    TrainingFocusCard(
                      primaryMuscle: _aggregates?.trainingFocus?.primaryMuscle,
                      percentage: _aggregates?.trainingFocus?.percentage,
                      hasEnoughData: _aggregates?.trainingFocus != null,
                    ),

                    const SizedBox(height: 16),

                    // AI Coach teaser
                    const AICoachTeaserCard(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRecentWorkoutsSection() {
    final recentWorkouts = _aggregates?.recentWorkouts ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Workouts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all stub
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFFFC4C02),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentWorkouts.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Color(0xFF757575),
                      size: 32,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No workouts yet',
                      style: TextStyle(
                        color: Color(0xFFB3B3B3),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentWorkouts
                .take(3)
                .map((workout) => _buildWorkoutItem(workout)),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(WorkoutHistoryEntry workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Date circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  workout.completedAt.day.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getMonthAbbr(workout.completedAt.month),
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Workout info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${workout.exerciseCount} exercises · ${_formatDuration(workout.duration)}',
                  style: const TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Chevron
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF757575),
          ),
        ],
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}
