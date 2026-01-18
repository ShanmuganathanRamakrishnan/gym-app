import 'package:flutter/material.dart';
import '../main.dart';
import '../models/routine.dart';

/// Sample exercise data with granular muscle groups
const List<Map<String, String>> _sampleExercises = [
  // Chest
  {'id': 'bench_press', 'name': 'Bench Press', 'muscle': 'Chest'},
  {
    'id': 'incline_db_press',
    'name': 'Incline Dumbbell Press',
    'muscle': 'Chest'
  },
  {'id': 'cable_fly', 'name': 'Cable Fly', 'muscle': 'Chest'},
  {'id': 'push_ups', 'name': 'Push Ups', 'muscle': 'Chest'},
  // Back
  {'id': 'deadlift', 'name': 'Deadlift', 'muscle': 'Back'},
  {'id': 'pull_ups', 'name': 'Pull Ups', 'muscle': 'Back'},
  {'id': 'barbell_row', 'name': 'Barbell Row', 'muscle': 'Back'},
  {'id': 'lat_pulldown', 'name': 'Lat Pulldown', 'muscle': 'Back'},
  {'id': 'cable_row', 'name': 'Seated Cable Row', 'muscle': 'Back'},
  // Shoulders
  {'id': 'shoulder_press', 'name': 'Shoulder Press', 'muscle': 'Shoulders'},
  {'id': 'lateral_raise', 'name': 'Lateral Raise', 'muscle': 'Shoulders'},
  {'id': 'face_pull', 'name': 'Face Pull', 'muscle': 'Shoulders'},
  {'id': 'front_raise', 'name': 'Front Raise', 'muscle': 'Shoulders'},
  // Biceps
  {'id': 'bicep_curl', 'name': 'Bicep Curl', 'muscle': 'Biceps'},
  {'id': 'hammer_curl', 'name': 'Hammer Curl', 'muscle': 'Biceps'},
  {'id': 'preacher_curl', 'name': 'Preacher Curl', 'muscle': 'Biceps'},
  // Triceps
  {'id': 'tricep_dips', 'name': 'Tricep Dips', 'muscle': 'Triceps'},
  {'id': 'tricep_pushdown', 'name': 'Tricep Pushdown', 'muscle': 'Triceps'},
  {
    'id': 'overhead_extension',
    'name': 'Overhead Extension',
    'muscle': 'Triceps'
  },
  {'id': 'skull_crushers', 'name': 'Skull Crushers', 'muscle': 'Triceps'},
  // Forearms
  {'id': 'wrist_curl', 'name': 'Wrist Curl', 'muscle': 'Forearms'},
  {'id': 'reverse_curl', 'name': 'Reverse Curl', 'muscle': 'Forearms'},
  // Quads
  {'id': 'squat', 'name': 'Squat', 'muscle': 'Quads'},
  {'id': 'leg_press', 'name': 'Leg Press', 'muscle': 'Quads'},
  {'id': 'lunges', 'name': 'Lunges', 'muscle': 'Quads'},
  {'id': 'leg_extension', 'name': 'Leg Extension', 'muscle': 'Quads'},
  // Hamstrings
  {
    'id': 'romanian_deadlift',
    'name': 'Romanian Deadlift',
    'muscle': 'Hamstrings'
  },
  {'id': 'leg_curl', 'name': 'Leg Curl', 'muscle': 'Hamstrings'},
  // Glutes
  {'id': 'hip_thrust', 'name': 'Hip Thrust', 'muscle': 'Glutes'},
  {'id': 'glute_bridge', 'name': 'Glute Bridge', 'muscle': 'Glutes'},
  // Calves
  {'id': 'calf_raise', 'name': 'Calf Raise', 'muscle': 'Calves'},
  {'id': 'seated_calf_raise', 'name': 'Seated Calf Raise', 'muscle': 'Calves'},
  // Core
  {'id': 'plank', 'name': 'Plank', 'muscle': 'Core'},
  {'id': 'crunches', 'name': 'Crunches', 'muscle': 'Core'},
  {'id': 'russian_twist', 'name': 'Russian Twist', 'muscle': 'Core'},
  {'id': 'hanging_leg_raise', 'name': 'Hanging Leg Raise', 'muscle': 'Core'},
];

/// Modal bottom sheet for selecting exercises (Fix #5 - improved visual clarity)
class AddExerciseModal extends StatefulWidget {
  /// List of exercise IDs already in the routine (for deduplication)
  final Set<String> existingExerciseIds;

  const AddExerciseModal({
    super.key,
    this.existingExerciseIds = const {},
  });

  @override
  State<AddExerciseModal> createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends State<AddExerciseModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _duplicateWarning; // Inline warning for duplicates

  List<Map<String, String>> get _filteredExercises {
    if (_searchQuery.isEmpty) return _sampleExercises;
    return _sampleExercises.where((ex) {
      final name = ex['name']!.toLowerCase();
      final muscle = ex['muscle']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || muscle.contains(query);
    }).toList();
  }

  void _selectExercise(Map<String, String> exercise) {
    final exerciseId = exercise['id']!;

    // Check for duplicate - show inline warning instead of Snackbar
    if (widget.existingExerciseIds.contains(exerciseId)) {
      setState(() {
        _duplicateWarning =
            'Exercise already in routine. Edit existing entry to change sets/reps/rest.';
      });
      // Auto-clear warning after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _duplicateWarning = null);
      });
      return; // Do not add duplicate
    }

    final routineExercise = RoutineExercise(
      exerciseId: exerciseId,
      name: exercise['name']!,
      // Uses defaults: sets=3, reps='8-12', restSeconds=60
      // User can edit in create_routine_screen
    );
    Navigator.of(context).pop(routineExercise);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Add Exercise',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Search (Fix #6 - better contrast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary),
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 12),

              // Duplicate warning banner (inline, visible above list)
              if (_duplicateWarning != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _duplicateWarning!,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _duplicateWarning = null),
                        child: const Icon(Icons.close,
                            color: Colors.orange, size: 18),
                      ),
                    ],
                  ),
                ),

              if (_duplicateWarning != null) const SizedBox(height: 8),

              // Exercise list (Fix #5 - improved spacing and contrast)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _filteredExercises[index];
                    return _ExerciseItem(
                      name: exercise['name']!,
                      muscle: exercise['muscle']!,
                      onTap: () => _selectExercise(exercise),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Exercise item with improved visual clarity (Fix #5, #6)
class _ExerciseItem extends StatelessWidget {
  final String name;
  final String muscle;
  final VoidCallback onTap;

  const _ExerciseItem({
    required this.name,
    required this.muscle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            // Text content with improved contrast
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    muscle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Add button - more visible (Fix #5)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.accent,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
