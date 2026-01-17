import 'package:flutter/material.dart';
import 'main.dart';
import 'models/routine.dart';
import 'services/routine_store.dart';
import 'data/prebuilt_routines.dart';
import 'screens/explore_routine_detail.dart';
import 'screens/active_workout_screen.dart';
import 'screens/create_routine_screen.dart';

/// Mock user experience level (would come from UserProfile)
const ExperienceLevel _userExperienceLevel = ExperienceLevel.intermediate;

/// Suggested workout for today (with exercises)
final Map<String, dynamic> _suggestedWorkout = {
  "title": "Upper Body Strength",
  "subtitle": "Chest · Shoulders · Triceps",
  "duration": "45 min",
  "exercises": <RoutineExercise>[
    RoutineExercise(
        exerciseId: 'bench_press', name: 'Bench Press', sets: 4, reps: '8-10'),
    RoutineExercise(
        exerciseId: 'incline_db_press',
        name: 'Incline Dumbbell Press',
        sets: 3,
        reps: '10-12'),
    RoutineExercise(
        exerciseId: 'shoulder_press',
        name: 'Shoulder Press',
        sets: 4,
        reps: '8-10'),
    RoutineExercise(
        exerciseId: 'lateral_raise',
        name: 'Lateral Raise',
        sets: 3,
        reps: '12-15'),
    RoutineExercise(
        exerciseId: 'tricep_pushdown',
        name: 'Tricep Pushdown',
        sets: 3,
        reps: '10-12'),
    RoutineExercise(
        exerciseId: 'overhead_extension',
        name: 'Overhead Tricep Extension',
        sets: 3,
        reps: '10-12'),
    RoutineExercise(
        exerciseId: 'cable_fly', name: 'Cable Fly', sets: 3, reps: '12-15'),
    RoutineExercise(
        exerciseId: 'face_pull', name: 'Face Pull', sets: 3, reps: '12-15'),
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

  // Explore filter state
  ExperienceLevel _selectedLevel = _userExperienceLevel;

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

  Future<void> _openExploreDetail(PrebuiltRoutine routine) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ExploreRoutineDetail(routine: routine)),
    );

    // Refresh if a routine was added
    if (result == true && mounted) {
      await _store.refresh();
      setState(() {});
    }
  }

  Future<void> _openCreateRoutine() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
    );

    // Refresh if a routine was created
    if (result == true && mounted) {
      await _store.refresh();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggested = _suggestedWorkout;

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
              _buildExploreFilters(),
              const SizedBox(height: 16),
              _buildExploreSection(context),
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
    final exercises = workout['exercises'] as List<RoutineExercise>;

    return GestureDetector(
      onTap: () async {
        // Start suggested workout with prefilled exercises
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActiveWorkoutScreen(
              workoutName: workout['title'] as String,
              preloadedExercises: exercises,
            ),
          ),
        );
        // Refresh after returning from workout
        if (mounted) {
          await _store.refresh();
          setState(() {});
        }
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
            Text(
              workout['title'] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              workout['subtitle'] as String,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMeta(Icons.timer_outlined, workout['duration'] as String),
                const SizedBox(width: 16),
                _buildMeta(Icons.format_list_numbered,
                    '${exercises.length} exercises'),
              ],
            ),
            const SizedBox(height: 16),
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
          child: _RoutineCard(
            routine: routine,
            onWorkoutComplete: () async {
              await _store.refresh();
              if (mounted) setState(() {});
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyRoutines(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              color: AppColors.textMuted,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No routines yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your own or add from Explore',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _openCreateRoutine,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Create Routine',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3) EXPLORE (with experience filter)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildExploreFilters() {
    return Row(
      children: ExperienceLevel.values.map((level) {
        final isSelected = _selectedLevel == level;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => setState(() => _selectedLevel = level),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.surfaceLight,
                  width: 1,
                ),
              ),
              child: Text(
                level.displayName,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExploreSection(BuildContext context) {
    final filteredRoutines = getRoutinesByLevel(_selectedLevel);

    if (filteredRoutines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            'No routines for this level',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: filteredRoutines.map((routine) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ExploreCard(
            routine: routine,
            store: _store,
            onTap: () => _openExploreDetail(routine),
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
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ActiveWorkoutScreen(
                workoutName: 'Freestyle Workout',
              ),
            ),
          );
          // Refresh after returning from workout
          if (mounted) {
            await _store.refresh();
            setState(() {});
          }
        },
        icon: const Icon(Icons.add_circle_outline, size: 22),
        label: const Text(
          'Start Empty Workout',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
  final VoidCallback? onWorkoutComplete;

  const _RoutineCard({required this.routine, this.onWorkoutComplete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Start workout from routine
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActiveWorkoutScreen(
              routineId: routine.id,
              workoutName: routine.name,
              preloadedExercises: routine.exercises,
            ),
          ),
        );
        // Refresh after workout
        onWorkoutComplete?.call();
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

/// Explore card for prebuilt routines
class _ExploreCard extends StatelessWidget {
  final PrebuiltRoutine routine;
  final RoutineStore store;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.routine,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              child: const Icon(Icons.auto_awesome,
                  color: AppColors.textSecondary, size: 22),
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
                  Row(
                    children: [
                      Text(
                        '${routine.daysPerWeek} days/week',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getLevelColor().withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          routine.level.displayName,
                          style: TextStyle(
                            color: _getLevelColor(),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Show checkmark if already added, otherwise chevron
            store.hasTemplate(routine.id)
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.accentDim,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.accent,
                      size: 16,
                    ),
                  )
                : const Icon(Icons.chevron_right,
                    color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor() {
    switch (routine.level) {
      case ExperienceLevel.beginner:
        return const Color(0xFF4CAF50);
      case ExperienceLevel.intermediate:
        return const Color(0xFFFFA726);
      case ExperienceLevel.advanced:
        return const Color(0xFFEF5350);
    }
  }
}
