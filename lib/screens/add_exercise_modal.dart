import 'package:flutter/material.dart';
import '../main.dart';
import '../models/routine.dart';

/// Sample exercise data
const List<Map<String, String>> _sampleExercises = [
  {'id': 'bench_press', 'name': 'Bench Press', 'muscle': 'Chest'},
  {
    'id': 'incline_db_press',
    'name': 'Incline Dumbbell Press',
    'muscle': 'Chest'
  },
  {'id': 'cable_fly', 'name': 'Cable Fly', 'muscle': 'Chest'},
  {'id': 'push_ups', 'name': 'Push Ups', 'muscle': 'Chest'},
  {'id': 'shoulder_press', 'name': 'Shoulder Press', 'muscle': 'Shoulders'},
  {'id': 'lateral_raise', 'name': 'Lateral Raise', 'muscle': 'Shoulders'},
  {'id': 'face_pull', 'name': 'Face Pull', 'muscle': 'Shoulders'},
  {'id': 'tricep_dips', 'name': 'Tricep Dips', 'muscle': 'Arms'},
  {'id': 'tricep_pushdown', 'name': 'Tricep Pushdown', 'muscle': 'Arms'},
  {'id': 'bicep_curl', 'name': 'Bicep Curl', 'muscle': 'Arms'},
  {'id': 'hammer_curl', 'name': 'Hammer Curl', 'muscle': 'Arms'},
  {'id': 'deadlift', 'name': 'Deadlift', 'muscle': 'Back'},
  {'id': 'pull_ups', 'name': 'Pull Ups', 'muscle': 'Back'},
  {'id': 'barbell_row', 'name': 'Barbell Row', 'muscle': 'Back'},
  {'id': 'lat_pulldown', 'name': 'Lat Pulldown', 'muscle': 'Back'},
  {'id': 'squat', 'name': 'Squat', 'muscle': 'Legs'},
  {'id': 'leg_press', 'name': 'Leg Press', 'muscle': 'Legs'},
  {'id': 'lunges', 'name': 'Lunges', 'muscle': 'Legs'},
  {'id': 'leg_curl', 'name': 'Leg Curl', 'muscle': 'Legs'},
  {'id': 'calf_raise', 'name': 'Calf Raise', 'muscle': 'Legs'},
  {'id': 'plank', 'name': 'Plank', 'muscle': 'Core'},
  {'id': 'crunches', 'name': 'Crunches', 'muscle': 'Core'},
  {'id': 'russian_twist', 'name': 'Russian Twist', 'muscle': 'Core'},
];

/// Modal bottom sheet for selecting exercises
class AddExerciseModal extends StatefulWidget {
  const AddExerciseModal({super.key});

  @override
  State<AddExerciseModal> createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends State<AddExerciseModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    final routineExercise = RoutineExercise(
      exerciseId: exercise['id']!,
      name: exercise['name']!,
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
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Add Exercise',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 12),

              // Exercise list
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    muscle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
