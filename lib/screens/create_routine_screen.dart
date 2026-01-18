import 'package:flutter/material.dart';
import '../main.dart';
import '../models/routine.dart';
import '../services/routine_store.dart';
import 'add_exercise_modal.dart';

/// Granular muscle group options (Fix #4)
const List<String> _muscleGroups = [
  'Chest',
  'Back',
  'Shoulders',
  'Biceps',
  'Triceps',
  'Forearms',
  'Quads',
  'Hamstrings',
  'Glutes',
  'Calves',
  'Core',
  'Full Body',
];

/// 3-step routine creation wizard
class CreateRoutineScreen extends StatefulWidget {
  final List<RoutineExercise>? prefillExercises;
  final String? prefillName;

  const CreateRoutineScreen({
    super.key,
    this.prefillExercises,
    this.prefillName,
  });

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Basics (NO duration - Fix #2)
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedFocus = {};

  // Step 2: Exercises
  final List<RoutineExercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    // Prefill if provided (from Save as Routine)
    if (widget.prefillName != null && widget.prefillName!.isNotEmpty) {
      _nameController.text = widget.prefillName!;
    }
    if (widget.prefillExercises != null) {
      _exercises.addAll(widget.prefillExercises!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinueStep1 => _nameController.text.trim().isNotEmpty;
  bool get _canContinueStep2 => _exercises.isNotEmpty;

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveRoutine() async {
    final store = RoutineStore();

    // Ensure store is initialized
    await store.init();

    // Check limit
    if (!store.canAddRoutine) {
      _showLimitModal();
      return;
    }

    final routine = Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      targetFocus: _selectedFocus.toList(),
      exercises: _exercises,
    );

    final success = await store.saveRoutine(routine);

    if (success && mounted) {
      // Navigate back to Workout tab root with success result
      Navigator.of(context).pop(true);
    } else if (!success && mounted) {
      _showLimitModal();
    }
  }

  void _showLimitModal() {
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
          "You've reached the free routine limit (3 routines). Upgrade to create unlimited routines.",
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

  Future<void> _openAddExercise() async {
    final result = await showModalBottomSheet<RoutineExercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddExerciseModal(),
    );

    if (result != null) {
      setState(() => _exercises.add(result));
    }
  }

  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
  }

  void _updateExercise(int index, RoutineExercise updated) {
    setState(() => _exercises[index] = updated);
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
          onPressed: _previousStep,
        ),
        title: Text(
          _getStepTitle(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Step ${_currentStep + 1} of 3',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1Basics(),
          _buildStep2Exercises(),
          _buildStep3Review(),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Routine Basics';
      case 1:
        return 'Add Exercises';
      case 2:
        return 'Review & Save';
      default:
        return 'Create Routine';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 1: BASICS (NO DURATION - Fix #2)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep1Basics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Routine Name
          const Text(
            'Routine Name',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'e.g., Monday Push Day',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 32),

          // Target Focus - Expanded muscle groups (Fix #4)
          const Text(
            'Target Muscles',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select muscle groups this routine targets',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _muscleGroups.map((muscle) {
              final isSelected = _selectedFocus.contains(muscle);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFocus.remove(muscle);
                    } else {
                      _selectedFocus.add(muscle);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentDim : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.surfaceLight,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    muscle,
                    style: TextStyle(
                      color:
                          isSelected ? AppColors.accent : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canContinueStep1 ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceLight,
                disabledForegroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 2: EXERCISES
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep2Exercises() {
    return Column(
      children: [
        // Header with routine name
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surface,
          child: Text(
            _nameController.text.trim().isEmpty
                ? 'New Routine'
                : _nameController.text.trim(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Exercise list
        Expanded(
          child: _exercises.isEmpty
              ? _buildEmptyExercises()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    return _ExerciseListItem(
                      exercise: _exercises[index],
                      index: index,
                      onRemove: () => _removeExercise(index),
                      onUpdate: (updated) => _updateExercise(index, updated),
                    );
                  },
                ),
        ),

        // Bottom actions
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: AppColors.surfaceLight, width: 1),
            ),
          ),
          child: Column(
            children: [
              // Add Exercise
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openAddExercise,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Exercise'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Continue
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinueStep2 ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceLight,
                    disabledForegroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyExercises() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_outlined,
                color: AppColors.textMuted,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No exercises added yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "Add Exercise" to build your routine',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 3: REVIEW (NO DURATION)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStep3Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Routine summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  _nameController.text.trim(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Focus chips
                if (_selectedFocus.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedFocus.map((f) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          f,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // Exercise count only (no duration)
                Row(
                  children: [
                    const Icon(Icons.format_list_numbered,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${_exercises.length} exercise${_exercises.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Exercise list
          const Text(
            'Exercises',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_exercises.length, (index) {
            final ex = _exercises[index];
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
                      ex.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${ex.sets}×${ex.reps}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 40),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveRoutine,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Routine',
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
// EXERCISE LIST ITEM (improved visual clarity - Fix #5)
// ═══════════════════════════════════════════════════════════════════════════

class _ExerciseListItem extends StatefulWidget {
  final RoutineExercise exercise;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<RoutineExercise> onUpdate;

  const _ExerciseListItem({
    required this.exercise,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  State<_ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<_ExerciseListItem> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _setsController =
        TextEditingController(text: widget.exercise.sets.toString());
    _repsController = TextEditingController(text: widget.exercise.reps);
    _restController =
        TextEditingController(text: widget.exercise.restSeconds.toString());
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _updateExercise() {
    final sets = int.tryParse(_setsController.text) ?? widget.exercise.sets;
    final reps = _repsController.text.isNotEmpty
        ? _repsController.text
        : widget.exercise.reps;
    final rest =
        int.tryParse(_restController.text) ?? widget.exercise.restSeconds;

    widget.onUpdate(widget.exercise.copyWith(
      sets: sets,
      reps: reps,
      restSeconds: rest,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.exercise.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textMuted,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Editable fields
          Row(
            children: [
              _buildEditableField(
                  'Sets', _setsController, TextInputType.number),
              const SizedBox(width: 12),
              _buildEditableField('Reps', _repsController, TextInputType.text),
              const SizedBox(width: 12),
              _buildEditableField(
                  'Rest (s)', _restController, TextInputType.number),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      TextInputType keyboardType) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceLight,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.accent, width: 1),
              ),
            ),
            onChanged: (_) => _updateExercise(),
          ),
        ],
      ),
    );
  }
}
