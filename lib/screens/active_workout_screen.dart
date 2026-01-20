import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/workout_session.dart';
import '../models/routine.dart';
import '../services/workout_session_store.dart';
import '../widgets/exercise_info_button.dart';
import 'workout_summary_screen.dart';

/// Full-screen active workout session
class ActiveWorkoutScreen extends StatefulWidget {
  final String? routineId;
  final String workoutName;
  final List<RoutineExercise>? preloadedExercises;

  const ActiveWorkoutScreen({
    super.key,
    this.routineId,
    required this.workoutName,
    this.preloadedExercises,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final WorkoutSessionStore _store = WorkoutSessionStore();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initSession() async {
    await _store.init();

    // Check for existing active session
    if (_store.hasActiveSession) {
      // Resume existing session
      setState(() {
        _elapsed = _store.activeSession!.totalDuration;
        _loading = false;
      });
    } else {
      // Start new session
      final exercises = widget.preloadedExercises?.map((e) {
        return WorkoutExercise(
          id: DateTime.now().millisecondsSinceEpoch.toString() + e.exerciseId,
          exerciseId: e.exerciseId,
          name: e.name,
          muscleGroup: '',
          targetReps: e.reps,
          restSeconds: e.restSeconds,
          sets: List.generate(e.sets, (i) => WorkoutSet(setNumber: i + 1)),
        );
      }).toList();

      await _store.startSession(
        routineId: widget.routineId,
        name: widget.workoutName,
        exercises: exercises,
      );

      setState(() => _loading = false);
    }

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_store.hasActiveSession) return;
      if (!_store.activeSession!.isPaused) {
        setState(() {
          _elapsed = _store.activeSession!.totalDuration;
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _togglePause() async {
    if (!_store.hasActiveSession) return;

    if (_store.activeSession!.isPaused) {
      await _store.resumeSession();
    } else {
      await _store.pauseSession();
    }
    setState(() {});
  }

  void _showEndWorkoutDialog() {
    final session = _store.activeSession;
    if (session == null) return;

    // Count incomplete sets (no reps AND no weight)
    int incompleteSets = 0;
    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (!set.completed && set.reps == 0 && set.weight == 0) {
          incompleteSets++;
        }
      }
    }

    final hasIncomplete = incompleteSets > 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          hasIncomplete ? 'Incomplete logging detected' : 'End Workout?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          hasIncomplete
              ? '$incompleteSets set${incompleteSets > 1 ? 's' : ''} have no reps or weight recorded. End workout anyway? Unsaved progress may be lost.'
              : 'Are you sure you want to finish this workout session?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endWorkout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: Text(hasIncomplete ? 'End anyway' : 'End Workout'),
          ),
        ],
      ),
    );
  }

  Future<void> _endWorkout() async {
    final session = await _store.endSession();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WorkoutSummaryScreen(session: session),
        ),
      );
    }
  }

  void _addExercise() {
    _showAddExerciseModal();
  }

  void _showAddExerciseModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddExerciseSheet(
        onExerciseSelected: (name, muscle) async {
          final exercise = WorkoutExercise(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            exerciseId: name.toLowerCase().replaceAll(' ', '_'),
            name: name,
            muscleGroup: muscle,
          );
          await _store.addExercise(exercise);
          setState(() {});
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final session = _store.activeSession;
    if (session == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: Text('No active session',
                style: TextStyle(color: AppColors.textPrimary))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(session),

            // Exercise List
            Expanded(
              child: session.exercises.isEmpty
                  ? _buildEmptyState()
                  : _buildExerciseList(session),
            ),

            // Bottom Controls
            _buildBottomControls(session),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WorkoutSession session) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.surfaceLight)),
      ),
      child: Row(
        children: [
          // Back / Close
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: _showEndWorkoutDialog,
          ),
          const SizedBox(width: 8),

          // Workout name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  session.isFreestyle ? 'Freestyle Workout' : 'Routine',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: session.isPaused
                  ? AppColors.surfaceLight
                  : AppColors.accentDim,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  session.isPaused ? Icons.pause : Icons.timer_outlined,
                  size: 18,
                  color:
                      session.isPaused ? AppColors.textMuted : AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(_elapsed),
                  style: TextStyle(
                    color: session.isPaused
                        ? AppColors.textMuted
                        : AppColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.textSecondary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No exercises yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add exercises to start your workout',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addExercise,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Exercise'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(WorkoutSession session) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: session.exercises.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == session.exercises.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: OutlinedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Exercise'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        }

        return _ExerciseCard(
          exercise: session.exercises[index],
          onSetUpdated: (setIndex, reps, weight, completed) async {
            await _store.updateSet(
              exerciseId: session.exercises[index].id,
              setIndex: setIndex,
              reps: reps,
              weight: weight,
              completed: completed,
            );
            setState(() {});
          },
          onAddSet: () async {
            await _store.addSet(session.exercises[index].id);
            setState(() {});
          },
          onSkip: () async {
            await _store.skipExercise(session.exercises[index].id);
            setState(() {});
          },
          onRemove: () async {
            await _store.removeExercise(session.exercises[index].id);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildBottomControls(WorkoutSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceLight)),
      ),
      child: Row(
        children: [
          // Pause/Resume
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _togglePause,
              icon: Icon(
                session.isPaused ? Icons.play_arrow : Icons.pause,
                size: 22,
              ),
              label: Text(session.isPaused ? 'Resume' : 'Pause'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.surfaceLight),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // End Workout
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _showEndWorkoutDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'End Workout',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE CARD
// ═══════════════════════════════════════════════════════════════════════════

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final Function(int setIndex, int? reps, double? weight, bool? completed)
      onSetUpdated;
  final VoidCallback onAddSet;
  final VoidCallback onSkip;
  final VoidCallback onRemove;

  const _ExerciseCard({
    required this.exercise,
    required this.onSetUpdated,
    required this.onAddSet,
    required this.onSkip,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: exercise.skipped ? AppColors.surfaceLight : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: TextStyle(
                                color: exercise.skipped
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                decoration: exercise.skipped
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (exercise.muscleGroup.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                exercise.muscleGroup,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ExerciseInfoButton(
                        exerciseId: exercise.exerciseId,
                        exerciseName: exercise.name,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                  color: AppColors.surface,
                  onSelected: (value) {
                    if (value == 'skip') onSkip();
                    if (value == 'remove') onRemove();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'skip',
                      child: Text('Skip Exercise',
                          style: TextStyle(color: AppColors.textPrimary)),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove',
                          style: TextStyle(color: Color(0xFFEF5350))),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!exercise.skipped) ...[
            // Sets header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                      width: 36,
                      child: Text('Set',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12))),
                  Expanded(
                      child: Center(
                          child: Text('Weight',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)))),
                  Expanded(
                      child: Center(
                          child: Text('Reps',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)))),
                  SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Sets list
            ...exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return _SetRow(
                key: ValueKey('${exercise.id}_$index'),
                set: set,
                restSeconds: exercise.restSeconds,
                onRepsChanged: (reps) => onSetUpdated(index, reps, null, null),
                onWeightChanged: (weight) =>
                    onSetUpdated(index, null, weight, null),
                onCompletedChanged: (completed) {
                  // DEBUG: Snackbar disabled for testing
                  // Validate: require reps OR weight before marking complete
                  // if (completed && set.reps == 0 && set.weight == 0) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text(
                  //         'Please log reps or weight for this set before marking it complete.',
                  //       ),
                  //       backgroundColor: AppColors.surface,
                  //       behavior: SnackBarBehavior.floating,
                  //       duration: Duration(seconds: 2),
                  //     ),
                  //   );
                  //   return; // Block completion
                  // }
                  onSetUpdated(index, null, null, completed);
                },
              );
            }),

            // Add set button
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: onAddSet,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.surfaceLight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '+ Add Set',
                      style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SET ROW
// ═══════════════════════════════════════════════════════════════════════════

class _SetRow extends StatefulWidget {
  final WorkoutSet set;
  final int restSeconds; // Rest duration from exercise
  final Function(int) onRepsChanged;
  final Function(double) onWeightChanged;
  final Function(bool) onCompletedChanged;

  const _SetRow({
    super.key,
    required this.set,
    required this.restSeconds,
    required this.onRepsChanged,
    required this.onWeightChanged,
    required this.onCompletedChanged,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  Timer? _restTimer;
  int _restSeconds = 0;

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSeconds = widget.restSeconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_restSeconds > 0) {
        setState(() => _restSeconds--);
      } else {
        _restTimer?.cancel();
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() => _restSeconds = 0);
  }

  void _resetRest() {
    setState(() => _restSeconds = widget.restSeconds);
  }

  void _showNumberInput(BuildContext context, String label, num currentValue,
      bool isDecimal, Function(num) onChanged) {
    final controller = TextEditingController(
        text: currentValue > 0 ? currentValue.toString() : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Enter $label',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 24),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          inputFormatters: isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
              : [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final value = isDecimal
                  ? double.tryParse(controller.text) ?? 0
                  : int.tryParse(controller.text) ?? 0;
              onChanged(value);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatRestTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final showRestTimer = _restSeconds > 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.set.completed
                ? AppColors.accentDim.withValues(alpha: 0.3)
                : Colors.transparent,
            border: showRestTimer
                ? Border.all(
                    color: AppColors.accent.withValues(alpha: 0.5), width: 2)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Set number
              SizedBox(
                width: 36,
                child: Text(
                  '${widget.set.setNumber}',
                  style: TextStyle(
                    color: widget.set.completed
                        ? AppColors.accent
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Weight
              Expanded(
                child: GestureDetector(
                  onTap: () => _showNumberInput(
                      context,
                      'Weight (kg)',
                      widget.set.weight,
                      true,
                      (v) => widget.onWeightChanged(v.toDouble())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.set.weight > 0 ? '${widget.set.weight} kg' : '-',
                        style: TextStyle(
                          color: widget.set.weight > 0
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Reps
              Expanded(
                child: GestureDetector(
                  onTap: () => _showNumberInput(
                      context,
                      'Reps',
                      widget.set.reps,
                      false,
                      (v) => widget.onRepsChanged(v.toInt())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.set.reps > 0 ? '${widget.set.reps}' : '-',
                        style: TextStyle(
                          color: widget.set.reps > 0
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Complete checkbox
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Prevent IME/focus issues by unfocusing any active input
                  FocusScope.of(context).unfocus();

                  final newCompleted = !widget.set.completed;
                  widget.onCompletedChanged(newCompleted);
                  if (newCompleted) {
                    _startRestTimer();
                  } else {
                    _skipRest();
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.set.completed
                        ? AppColors.accent
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.set.completed ? Icons.check : Icons.circle_outlined,
                    color: widget.set.completed
                        ? Colors.white
                        : AppColors.textMuted,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Rest timer indicator
        if (showRestTimer)
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined,
                    size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  'Rest: ${_formatRestTime(_restSeconds)}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _skipRest,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _resetRest,
                  child: const Icon(Icons.refresh,
                      size: 18, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADD EXERCISE SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _AddExerciseSheet extends StatefulWidget {
  final Function(String name, String muscle) onExerciseSelected;

  const _AddExerciseSheet({required this.onExerciseSelected});

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  static const List<Map<String, String>> _exercises = [
    {'name': 'Bench Press', 'muscle': 'Chest'},
    {'name': 'Incline Dumbbell Press', 'muscle': 'Chest'},
    {'name': 'Cable Fly', 'muscle': 'Chest'},
    {'name': 'Push Ups', 'muscle': 'Chest'},
    {'name': 'Pull Ups', 'muscle': 'Back'},
    {'name': 'Lat Pulldown', 'muscle': 'Back'},
    {'name': 'Barbell Row', 'muscle': 'Back'},
    {'name': 'Deadlift', 'muscle': 'Back'},
    {'name': 'Shoulder Press', 'muscle': 'Shoulders'},
    {'name': 'Lateral Raise', 'muscle': 'Shoulders'},
    {'name': 'Face Pull', 'muscle': 'Shoulders'},
    {'name': 'Bicep Curl', 'muscle': 'Biceps'},
    {'name': 'Hammer Curl', 'muscle': 'Biceps'},
    {'name': 'Tricep Pushdown', 'muscle': 'Triceps'},
    {'name': 'Skull Crushers', 'muscle': 'Triceps'},
    {'name': 'Tricep Dips', 'muscle': 'Triceps'},
    {'name': 'Squat', 'muscle': 'Quads'},
    {'name': 'Leg Press', 'muscle': 'Quads'},
    {'name': 'Leg Extension', 'muscle': 'Quads'},
    {'name': 'Romanian Deadlift', 'muscle': 'Hamstrings'},
    {'name': 'Leg Curl', 'muscle': 'Hamstrings'},
    {'name': 'Hip Thrust', 'muscle': 'Glutes'},
    {'name': 'Calf Raise', 'muscle': 'Calves'},
    {'name': 'Plank', 'muscle': 'Core'},
    {'name': 'Cable Crunch', 'muscle': 'Core'},
  ];

  List<Map<String, String>> get _filteredExercises {
    if (_filter.isEmpty) return _exercises;
    return _exercises.where((e) {
      return e['name']!.toLowerCase().contains(_filter.toLowerCase()) ||
          e['muscle']!.toLowerCase().contains(_filter.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Add Exercise',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filter = value),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                return GestureDetector(
                  onTap: () => widget.onExerciseSelected(
                      exercise['name']!, exercise['muscle']!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise['name']!,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                exercise['muscle']!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.add_circle_outline,
                            color: AppColors.accent),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
