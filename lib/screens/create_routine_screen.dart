import 'package:flutter/material.dart';
import '../main.dart';
import '../models/routine.dart';
import '../services/routine_store.dart';
import 'add_exercise_modal.dart';

/// 3-step routine creation wizard
class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Basics
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedFocus = {};
  int _durationMinutes = 45;

  // Step 2: Exercises
  final List<RoutineExercise> _exercises = [];

  // Focus options
  static const List<String> _focusOptions = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Full Body',
  ];

  static const List<int> _durationOptions = [30, 45, 60, 90];

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

    // Check limit
    if (!store.canAddRoutine) {
      _showLimitModal();
      return;
    }

    final routine = Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      targetFocus: _selectedFocus.toList(),
      durationMinutes: _durationMinutes,
      exercises: _exercises,
    );

    final success = await store.saveRoutine(routine);

    if (success && mounted) {
      // Navigate back to Workout tab root
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
          style: TextStyle(color: AppColors.textSecondary),
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
                  color: AppColors.textMuted,
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
  // STEP 1: BASICS
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.textPrimary),
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
                vertical: 14,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 28),

          // Target Focus
          const Text(
            'Target Focus',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select muscle groups this routine targets',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _focusOptions.map((focus) {
              final isSelected = _selectedFocus.contains(focus);
              return FilterChip(
                label: Text(focus),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFocus.add(focus);
                    } else {
                      _selectedFocus.remove(focus);
                    }
                  });
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.accentDim,
                checkmarkColor: AppColors.accent,
                labelStyle: TextStyle(
                  color:
                      isSelected ? AppColors.accent : AppColors.textSecondary,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.accent : AppColors.surfaceLight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Duration
          const Text(
            'Estimated Duration',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _durationMinutes,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                icon: const Icon(Icons.expand_more, color: AppColors.textMuted),
                items: _durationOptions.map((mins) {
                  return DropdownMenuItem(
                    value: mins,
                    child: Text('$mins minutes'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _durationMinutes = value);
                },
              ),
            ),
          ),
          const SizedBox(height: 40),

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: AppColors.surface,
          child: Text(
            _nameController.text.trim().isEmpty
                ? 'New Routine'
                : _nameController.text.trim(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
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
                      onRemove: () => _removeExercise(index),
                      onUpdate: (updated) => _updateExercise(index, updated),
                    );
                  },
                ),
        ),

        // Bottom actions
        Container(
          padding: const EdgeInsets.all(20),
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
                    side: const BorderSide(color: AppColors.accent),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center_outlined,
            color: AppColors.textMuted,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No exercises added yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap "Add Exercise" to get started',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 3: REVIEW
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
                const SizedBox(height: 8),

                // Focus chips
                if (_selectedFocus.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    children: _selectedFocus.map((f) {
                      return Chip(
                        label: Text(f),
                        labelStyle: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                        ),
                        backgroundColor: AppColors.accentDim,
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Meta row
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '$_durationMinutes min',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.format_list_numbered,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${_exercises.length} exercises',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Exercise list
          const Text(
            'Exercises',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_exercises.length, (index) {
            final ex = _exercises[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ex.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${ex.sets}×${ex.reps}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
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
// EXERCISE LIST ITEM
// ═══════════════════════════════════════════════════════════════════════════

class _ExerciseListItem extends StatelessWidget {
  final RoutineExercise exercise;
  final VoidCallback onRemove;
  final ValueChanged<RoutineExercise> onUpdate;

  const _ExerciseListItem({
    required this.exercise,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
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
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textMuted,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Editable fields
          Row(
            children: [
              _buildField('Sets', exercise.sets.toString(), (value) {
                final sets = int.tryParse(value) ?? exercise.sets;
                onUpdate(exercise.copyWith(sets: sets));
              }),
              const SizedBox(width: 12),
              _buildField('Reps', exercise.reps, (value) {
                onUpdate(exercise.copyWith(reps: value));
              }),
              const SizedBox(width: 12),
              _buildField('Rest', '${exercise.restSeconds}s', (value) {
                final rest = int.tryParse(value.replaceAll('s', '')) ??
                    exercise.restSeconds;
                onUpdate(exercise.copyWith(restSeconds: rest));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      String label, String value, ValueChanged<String> onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
