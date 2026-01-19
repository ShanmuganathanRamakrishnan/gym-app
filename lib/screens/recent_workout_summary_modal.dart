import 'package:flutter/material.dart';
import '../main.dart';
import '../services/workout_history_service.dart';

/// Modal to display read-only summary of recent workout(s)
class RecentWorkoutSummaryModal extends StatefulWidget {
  final GroupedHistoryEntry group;

  const RecentWorkoutSummaryModal({
    super.key,
    required this.group,
  });

  /// Track if a modal is currently open to prevent multiple opens
  static bool _isOpen = false;

  /// Show the modal as a bottom sheet (guarded against multiple opens)
  static Future<void> show(
      BuildContext context, GroupedHistoryEntry group) async {
    // Prevent opening multiple sheets simultaneously
    if (_isOpen) return;

    _isOpen = true;
    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: true,
        builder: (_) => RecentWorkoutSummaryModal(group: group),
      );
    } finally {
      _isOpen = false;
    }
  }

  @override
  State<RecentWorkoutSummaryModal> createState() =>
      _RecentWorkoutSummaryModalState();
}

class _RecentWorkoutSummaryModalState extends State<RecentWorkoutSummaryModal> {
  late DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.7,
      minChildSize: 0.4,
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
              _buildHeader(),
              const Divider(color: AppColors.surfaceLight, height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: widget.group.isGrouped
                      ? _buildGroupedContent()
                      : _buildSingleContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final title = widget.group.isGrouped
        ? '${widget.group.name} — ${widget.group.sessionCount} sessions'
        : widget.group.name;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.group.isFreestyle
                  ? AppColors.surfaceLight
                  : AppColors.accentDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.group.isFreestyle ? Icons.flash_on : Icons.fitness_center,
              color: widget.group.isFreestyle
                  ? AppColors.textSecondary
                  : AppColors.accent,
              size: 22,
            ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRelativeDate(widget.group.date),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSingleContent() {
    final entry = widget.group.entries.first;
    return [
      _buildSummaryCard(entry),
      const SizedBox(height: 16),
      _buildMetadataRow(entry),
    ];
  }

  List<Widget> _buildGroupedContent() {
    return [
      // Aggregated summary
      _buildAggregatedSummary(),
      const SizedBox(height: 20),

      // Individual sessions
      const Text(
        'Sessions',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      ...widget.group.entries.map((entry) => _buildSessionCard(entry)),
    ];
  }

  Widget _buildAggregatedSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('Sessions', '${widget.group.sessionCount}'),
          _buildStatColumn(
              'Duration', '${widget.group.totalDuration.inMinutes} min'),
          _buildStatColumn('Exercises', '${widget.group.totalExercises}'),
          _buildStatColumn('Sets', '${widget.group.totalSets}'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(WorkoutHistoryEntry entry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Duration', '${entry.duration.inMinutes} min'),
              _buildStatColumn('Exercises', '${entry.exerciseCount}'),
              _buildStatColumn('Sets', '${entry.totalSets}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(WorkoutHistoryEntry entry) {
    final timeStr = _formatTime(entry.completedAt);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 8),
          Text(
            'Completed at $timeStr',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(WorkoutHistoryEntry entry) {
    final timeStr = _formatTime(entry.completedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.exerciseCount} exercises • ${entry.totalSets} sets',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.duration.inMinutes} min',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatRelativeDate(DateTime completedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedDate =
        DateTime(completedAt.year, completedAt.month, completedAt.day);
    final difference = today.difference(completedDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '$difference days ago';
  }
}
