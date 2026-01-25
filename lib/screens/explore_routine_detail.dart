import 'package:flutter/material.dart';
import '../main.dart';
import '../data/prebuilt_routines.dart';
import '../services/routine_store.dart';
import '../widgets/exercise_info_button.dart';

/// Read-only detail screen for prebuilt routines
class ExploreRoutineDetail extends StatefulWidget {
  final PrebuiltRoutine routine;

  const ExploreRoutineDetail({super.key, required this.routine});

  @override
  State<ExploreRoutineDetail> createState() => _ExploreRoutineDetailState();
}

class _ExploreRoutineDetailState extends State<ExploreRoutineDetail> {
  final RoutineStore _store = RoutineStore();
  bool _isAlreadyAdded = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkIfAdded();
  }

  Future<void> _checkIfAdded() async {
    await _store.init();
    if (mounted) {
      setState(() {
        _isAlreadyAdded = _store.hasTemplate(widget.routine.id);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Routine Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header card
                        _buildHeaderCard(),
                        const SizedBox(height: 28),

                        // Exercise list
                        const Text(
                          'Exercises',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...widget.routine.exercises
                            .asMap()
                            .entries
                            .map((entry) {
                          return _buildExerciseItem(entry.key, entry.value);
                        }),
                      ],
                    ),
                  ),
                ),

                // Bottom CTA
                _buildBottomCTA(context),
              ],
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Experience badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getLevelColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.routine.level.displayName,
              style: TextStyle(
                color: _getLevelColor(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            widget.routine.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          if (widget.routine.description.isNotEmpty) ...[
            Text(
              widget.routine.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Meta row
          Row(
            children: [
              _buildMetaItem(Icons.calendar_today_outlined,
                  '${widget.routine.daysPerWeek} days/week'),
              const SizedBox(width: 20),
              _buildMetaItem(Icons.format_list_numbered,
                  '${widget.routine.exercises.length} exercises'),
            ],
          ),
          const SizedBox(height: 14),

          // Focus areas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.routine.focusAreas.map((focus) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  focus,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItem(int index, dynamic exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              exercise.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ExerciseInfoButton(
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.name,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            '${exercise.sets}×${exercise.reps}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.surfaceLight, width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isAlreadyAdded ? null : () => _addToMyRoutines(context),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isAlreadyAdded ? AppColors.surfaceLight : AppColors.accent,
            foregroundColor:
                _isAlreadyAdded ? AppColors.textMuted : Colors.white,
            disabledBackgroundColor: AppColors.surfaceLight,
            disabledForegroundColor: AppColors.textMuted,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            _isAlreadyAdded ? 'Already Added' : 'Add to My Routines',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor() {
    switch (widget.routine.level) {
      case ExperienceLevel.beginner:
        return const Color(0xFF4CAF50); // Green
      case ExperienceLevel.intermediate:
        return const Color(0xFFFFA726); // Orange
      case ExperienceLevel.advanced:
        return const Color(0xFFEF5350); // Red
    }
  }

  Future<void> _addToMyRoutines(BuildContext context) async {
    // Double-check limit before adding
    if (!_store.canAddRoutine) {
      _showLimitModal(context);
      return;
    }

    // Clone and save (RoutineStore will check for duplicates)
    final userRoutine = widget.routine.toUserRoutine();
    final success = await _store.saveRoutine(userRoutine);

    if (!context.mounted) return;

    if (success) {
      // Navigate back to Workout tab
      Navigator.of(context).pop(true);
    } else {
      if (!mounted) return;
      // Failed - either limit reached or duplicate
      if (_store.hasTemplate(widget.routine.id)) {
        // Duplicate - update UI
        setState(() => _isAlreadyAdded = true);
      } else {
        // Limit reached
        _showLimitModal(context);
      }
    }
  }

  void _showLimitModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Routine Limit Reached",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          "You've reached the free routine limit (3 routines). Upgrade to add unlimited routines.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Upgrade Later',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
