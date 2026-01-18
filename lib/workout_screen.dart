import 'package:flutter/material.dart';
import 'main.dart';
import 'models/routine.dart';
import 'services/routine_store.dart';
import 'services/suggested_workout_service.dart';
import 'services/user_preferences.dart';
import 'services/workout_history_service.dart';
import 'data/prebuilt_routines.dart';
import 'screens/explore_routine_detail.dart';
import 'screens/active_workout_screen.dart';
import 'screens/create_routine_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final RoutineStore _store = RoutineStore();
  final SuggestedWorkoutService _suggestionService = SuggestedWorkoutService();
  final UserPreferences _userPrefs = UserPreferences();
  final WorkoutHistoryService _historyService = WorkoutHistoryService();
  bool _loading = true;
  SuggestedWorkout? _suggestedWorkout;
  ExperienceLevel _userLevel = ExperienceLevel.intermediate;

  // Explore filter state
  late ExperienceLevel _selectedLevel;

  @override
  void initState() {
    super.initState();
    _initStore();
  }

  Future<void> _initStore() async {
    await _store.init();
    await _userPrefs.init();
    await _historyService.init();

    // Get user's experience level
    _userLevel = _userPrefs.getExperienceLevelOrDefault();
    _selectedLevel = _userLevel;

    // Get workout history for suggestions
    final lastRoutineId = _historyService.lastCompletedRoutineId;
    final recentIds = _historyService.getRecentRoutineIds();

    // Get suggested workout
    _suggestedWorkout = await _suggestionService.getSuggestedWorkout(
      userLevel: _userLevel,
      lastCompletedRoutineId: lastRoutineId,
      recentRoutineIds: recentIds.isNotEmpty ? recentIds : null,
    );

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
    if (_loading || _suggestedWorkout == null) {
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
              _buildSuggestedCard(context, _suggestedWorkout!),
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
  Widget _buildSuggestedCard(BuildContext context, SuggestedWorkout suggested) {
    return GestureDetector(
      onTap: () async {
        // Start suggested workout with prefilled exercises
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActiveWorkoutScreen(
              workoutName: suggested.name,
              preloadedExercises: suggested.exercises,
            ),
          ),
        );
        // Refresh after returning from workout
        if (mounted) {
          _suggestionService.invalidateCache();
          await _store.refresh();
          _suggestedWorkout = await _suggestionService.getSuggestedWorkout(
            userLevel: _userLevel,
            lastCompletedRoutineId: null,
            recentRoutineIds: null,
          );
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
              suggested.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              suggested.subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMeta(Icons.timer_outlined, '~45 min'),
                const SizedBox(width: 16),
                _buildMeta(Icons.format_list_numbered,
                    '${suggested.exerciseCount} exercises'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ActiveWorkoutScreen(
                        workoutName: suggested.name,
                        preloadedExercises: suggested.exercises,
                      ),
                    ),
                  );
                  // Refresh after returning from workout
                  if (mounted) {
                    _suggestionService.invalidateCache();
                    await _store.refresh();
                    _suggestedWorkout =
                        await _suggestionService.getSuggestedWorkout(
                      userLevel: _userLevel,
                      lastCompletedRoutineId: null,
                      recentRoutineIds: null,
                    );
                    setState(() {});
                  }
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
        final routineIndex = _store.getRoutineIndex(routine.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: Key(routine.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmDeleteRoutine(context, routine.name),
            onDismissed: (_) =>
                _deleteRoutineWithUndo(context, routine, routineIndex),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.delete_outline, color: Colors.white, size: 22),
                ],
              ),
            ),
            child: _RoutineCard(
              routine: routine,
              onWorkoutComplete: () async {
                await _store.refresh();
                if (mounted) setState(() {});
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<bool> _confirmDeleteRoutine(
      BuildContext context, String routineName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Delete this routine?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Are you sure you want to delete "$routineName"?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _deleteRoutineWithUndo(
      BuildContext context, Routine routine, int index) async {
    // Capture scaffold messenger before async gap
    final messenger = ScaffoldMessenger.of(context);

    final deletedRoutine = await _store.deleteRoutineById(routine.id);
    if (mounted) setState(() {});

    if (deletedRoutine != null && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.accent, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Routine deleted',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _store.restoreRoutine(deletedRoutine, index);
                  if (mounted) setState(() {});
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accentDim,
                  foregroundColor: AppColors.accent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'UNDO',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          duration: const Duration(seconds: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }
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
