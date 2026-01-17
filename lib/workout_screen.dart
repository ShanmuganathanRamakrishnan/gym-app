import 'package:flutter/material.dart';
import 'main.dart';
import 'models/routine.dart';
import 'services/routine_store.dart';
import 'screens/create_routine_screen.dart';

/// Mock data for Workout tab
final Map<String, dynamic> workoutData = {
  "suggested": {
    "title": "Upper Body Strength",
    "subtitle": "Chest · Shoulders · Triceps",
    "duration": "45 min",
    "exercises": 8,
  },
  "explore": [
    {
      "title": "Push / Pull / Legs",
      "days": "6 days/week",
      "icon": Icons.repeat
    },
    {"title": "Upper / Lower", "days": "4 days/week", "icon": Icons.swap_vert},
    {
      "title": "Full Body",
      "days": "3 days/week",
      "icon": Icons.accessibility_new
    },
  ],
};

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final RoutineStore _store = RoutineStore();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initStore();
  }

  Future<void> _initStore() async {
    await _store.init();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _openCreateRoutine() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
    );

    // Refresh if a routine was saved
    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggested = workoutData['suggested'] as Map<String, dynamic>;
    final explore = workoutData['explore'] as List<dynamic>;

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Workouts',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // 1) SUGGESTED FOR TODAY
              _buildSectionTitle(context, 'Suggested for Today'),
              const SizedBox(height: 12),
              _buildSuggestedCard(context, suggested),
              const SizedBox(height: 28),

              // 2) MY ROUTINES
              _buildSectionTitle(context, 'My Routines'),
              const SizedBox(height: 12),
              _buildRoutinesSection(context),
              const SizedBox(height: 28),

              // 3) EXPLORE
              _buildSectionTitle(context, 'Explore'),
              const SizedBox(height: 12),
              _buildExploreSection(context, explore),
              const SizedBox(height: 28),

              // 4) START EMPTY WORKOUT
              _buildEmptyWorkoutCTA(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1) SUGGESTED FOR TODAY
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSuggestedCard(
      BuildContext context, Map<String, dynamic> workout) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to active workout flow
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'RECOMMENDED',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              workout['title'] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              workout['subtitle'] as String,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // Meta row
            Row(
              children: [
                _buildMeta(Icons.timer_outlined, workout['duration'] as String),
                const SizedBox(width: 16),
                _buildMeta(Icons.format_list_numbered,
                    '${workout['exercises']} exercises'),
              ],
            ),
            const SizedBox(height: 16),

            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Start this workout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Start Workout',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2) MY ROUTINES
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRoutinesSection(BuildContext context) {
    final routines = _store.routines;

    if (routines.isEmpty) {
      return _buildEmptyRoutines(context);
    }

    return Column(
      children: routines.map((routine) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RoutineCard(routine: routine),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyRoutines(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight, width: 1),
      ),
      child: Column(
        children: [
          // Icon container for visual grouping
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              color: AppColors.textSecondary,
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No routines yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a custom routine to get started',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _openCreateRoutine,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Create Routine'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3) EXPLORE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildExploreSection(BuildContext context, List<dynamic> items) {
    return Column(
      children: items.map((item) {
        final data = item as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ExploreCard(
            title: data['title'] as String,
            subtitle: data['days'] as String,
            icon: data['icon'] as IconData,
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4) START EMPTY WORKOUT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyWorkoutCTA(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Start empty workout
        },
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Start Empty Workout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.surfaceLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

/// Routine card for saved routines
class _RoutineCard extends StatelessWidget {
  final Routine routine;

  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to routine details / start
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center,
                  color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${routine.exercises.length} exercise${routine.exercises.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Explore program card
class _ExploreCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ExploreCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: View program details
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
