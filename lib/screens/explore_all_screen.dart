import 'package:flutter/material.dart';
import '../main.dart';
import '../data/prebuilt_routines.dart';
import '../services/routine_store.dart';
import 'explore_routine_detail.dart';
import 'create_routine_screen.dart';

/// Full-screen view of all prebuilt routines
class ExploreAllScreen extends StatefulWidget {
  const ExploreAllScreen({super.key});

  @override
  State<ExploreAllScreen> createState() => _ExploreAllScreenState();
}

class _ExploreAllScreenState extends State<ExploreAllScreen> {
  final RoutineStore _store = RoutineStore();
  ExperienceLevel _selectedLevel = ExperienceLevel.intermediate;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _store.init();
    if (mounted) setState(() => _loading = false);
  }

  List<PrebuiltRoutine> get _filteredRoutines =>
      getRoutinesByLevel(_selectedLevel);

  Future<void> _openCreateRoutine() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
    );
    if (result == true && mounted) {
      await _store.refresh();
      setState(() {});
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
          'Explore Routines',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _openCreateRoutine,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppColors.accent, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Create',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : Column(
              children: [
                // Level filters
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: ExperienceLevel.values.map((level) {
                      final isSelected = _selectedLevel == level;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedLevel = level),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              level.name[0].toUpperCase() +
                                  level.name.substring(1),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Routine list
                Expanded(
                  child: _filteredRoutines.isEmpty
                      ? const Center(
                          child: Text(
                            'No routines for this level',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: _filteredRoutines.length,
                          itemBuilder: (context, index) {
                            final routine = _filteredRoutines[index];
                            return _RoutineCard(
                              routine: routine,
                              store: _store,
                              onTap: () => _openDetail(routine),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _openDetail(PrebuiltRoutine routine) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExploreRoutineDetail(routine: routine)),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final PrebuiltRoutine routine;
  final RoutineStore store;
  final VoidCallback onTap;

  const _RoutineCard({
    required this.routine,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAdded = store.hasTemplate(routine.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${routine.daysPerWeek} days/week • ${routine.exercises.length} exercises',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Badge
            if (isAdded)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Added',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
