import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';
import '../services/workout_history_service.dart';
import '../services/calendar_service.dart';
import '../services/export_service.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/calendar_year_overview.dart';
import 'day_workouts_sheet.dart';

enum CalendarViewMode { month, year }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarService _calendarService = CalendarService();
  final ExportService _exportService = ExportService(); // Added ExportService

  // State
  bool _exporting = false; // Added exporting state
  CalendarViewMode _viewMode = CalendarViewMode.month;
  late DateTime _focusedMonth;
  late int _focusedYear; // Track separate focused year for Year View paging

  Map<DateTime, List<WorkoutHistoryEntry>> _events = {};
  Set<DateTime> _activeDays = {}; // Lightweight set for year view

  bool _loading = true;
  late PageController _monthPageController;
  late PageController _yearPageController;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _focusedYear = now.year;

    // Start PageControllers
    // For months: 1200 as midpoint
    _monthPageController = PageController(initialPage: 1200);
    // For years: 100 as midpoint (2026 +/- 100 years is enough)
    _yearPageController = PageController(initialPage: 100);

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // Load events for month view (detailed)
    // NOTE: Current service loads all history anyway, but we follow the method signature
    final events = await _calendarService.getEventsForMonth(_focusedMonth);

    // Load active days for year view
    final activeDays =
        await _calendarService.getActiveDaysForYear(_focusedYear);

    if (mounted) {
      setState(() {
        _events = events;
        _activeDays = activeDays;
        _loading = false;
      });
    }
  }

  void _onMonthPageChanged(int page) {
    final now = DateTime.now();
    final initialMonth = DateTime(now.year, now.month);
    final offset = page - 1200;
    final newMonth = DateTime(initialMonth.year, initialMonth.month + offset);

    setState(() {
      _focusedMonth = newMonth;
      // Sync year focus when scrolling months
      if (_focusedYear != newMonth.year) {
        _focusedYear = newMonth.year; // Keep year view synced in background
      }
    });
    // Optimistic UI, assuming data loaded, but could trigger reload here
  }

  void _onYearPageChanged(int page) {
    final now = DateTime.now();
    final offset = page - 100;
    final newYear = now.year + offset;

    setState(() {
      _focusedYear = newYear;
    });
    // Reload active days for new year
    _calendarService.getActiveDaysForYear(newYear).then((days) {
      if (mounted) setState(() => _activeDays = days);
    });
  }

  void _toggleViewMode() {
    setState(() {
      if (_viewMode == CalendarViewMode.month) {
        // Switch to Year
        _viewMode = CalendarViewMode.year;
        _focusedYear = _focusedMonth.year;

        final now = DateTime.now();
        final offset = _focusedYear - now.year;

        // Wait for View to attach
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_yearPageController.hasClients) {
            _yearPageController.jumpToPage(100 + offset);
          }
        });

        // Ensure data exists
        _calendarService.getActiveDaysForYear(_focusedYear).then((days) {
          if (mounted) setState(() => _activeDays = days);
        });
      } else {
        // Switch to Month
        _viewMode = CalendarViewMode.month;
        // Focus stays on the last interacted element?
        // Or should we focus a specific month?
        // Let's keep _focusedMonth as is unless specifically changed.
      }
    });
  }

  void _onMonthTapInYearView(DateTime month) {
    setState(() {
      _focusedMonth = month;
      _viewMode = CalendarViewMode.month;

      // Sync month page controller
      final now = DateTime.now();
      // Calculate total months difference
      final diffYears = month.year - now.year;
      final diffMonths = month.month - now.month;
      final totalOffset = (diffYears * 12) + diffMonths;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_monthPageController.hasClients) {
          _monthPageController.jumpToPage(1200 + totalOffset);
        }
      });
    });
  }

  Future<void> _onExportTap() async {
    setState(() => _exporting = true);

    try {
      DateTime start;
      DateTime end;
      String filename;

      if (_viewMode == CalendarViewMode.month) {
        start = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
        end = DateTime(
            _focusedMonth.year, _focusedMonth.month + 1, 0); // Last day
        final monthName = _months[_focusedMonth.month - 1]; // "January"
        filename = 'workouts_${monthName}_${_focusedMonth.year}.csv';
      } else {
        start = DateTime(_focusedYear, 1, 1);
        end = DateTime(_focusedYear, 12, 31);
        filename = 'workouts_$_focusedYear.csv';
      }

      final workouts = await _calendarService.getEventsInRange(start, end);

      if (workouts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No valid workouts found in this period.')),
          );
        }
        return;
      }

      await _exportService.exportWorkouts(workouts, filename: filename);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showDayDetails(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final workouts = _events[dateKey] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayWorkoutsSheet(
        date: date,
        workouts: workouts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _viewMode == CalendarViewMode.month
        ? '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}'
        : _focusedYear.toString();

    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        leading: const BackButton(),
        title: GestureDetector(
          onTap: _toggleViewMode,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: GymTheme.text.screenTitle),
              const SizedBox(width: 4),
              Icon(
                _viewMode == CalendarViewMode.month
                    ? Icons.arrow_drop_down
                    : Icons.arrow_drop_up,
                color: GymTheme.colors.accent,
              ),
            ],
          ),
        ),
        actions: [
          if (_exporting)
            const Center(
                child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
            ))
          else
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _onExportTap,
            ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent))
          : Column(
              children: [
                // Navigation Header (Chevrons)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () {
                          if (_viewMode == CalendarViewMode.month) {
                            _monthPageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          } else {
                            _yearPageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          }
                        },
                      ),
                      // Spacer or Centered "Select Year/Month" hint if needed?
                      // Actually header title handles label. Chevrons just act on current view.
                      const SizedBox(width: 40), // Balance layout
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.white),
                        onPressed: () {
                          if (_viewMode == CalendarViewMode.month) {
                            _monthPageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          } else {
                            _yearPageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Weekday Headers (Only for Month View)
                if (_viewMode == CalendarViewMode.month)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(7, (index) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              _weekdays[index],
                              style: TextStyle(
                                color: GymTheme.colors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                const SizedBox(height: 8),

                // Main Content (Switcher)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _viewMode == CalendarViewMode.month
                        ? PageView.builder(
                            key: const ValueKey('month_view'),
                            controller: _monthPageController,
                            onPageChanged: _onMonthPageChanged,
                            itemBuilder: (context, index) {
                              final now = DateTime.now();
                              final initialMonth =
                                  DateTime(now.year, now.month);
                              final offset = index - 1200;
                              final month = DateTime(initialMonth.year,
                                  initialMonth.month + offset);

                              return _buildMonthGrid(month);
                            },
                          )
                        : PageView.builder(
                            key: const ValueKey('year_view'),
                            controller: _yearPageController,
                            onPageChanged: _onYearPageChanged,
                            itemBuilder: (context, index) {
                              final now = DateTime.now();
                              final offset = index - 100;
                              final year = now.year + offset;

                              return CalendarYearOverview(
                                year: year,
                                activeDays:
                                    _activeDays, // This might need per-page loading if we scroll fast?
                                // Actually _activeDays is currently just focused year.
                                // If scrolling, we are updating _activeDays in onPageChanged.
                                // There might be a split second lag.
                                // For MVP this is acceptable (Hevy also loads).
                                onMonthTap: _onMonthTapInYearView,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final days = _getDaysInGrid(month);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(), // Managed by PageView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
        final dateKey = DateTime(date.year, date.month, date.day);
        final isOutside = date.month != month.month;
        final isToday = date.isAtSameMomentAs(today);
        final workouts = _events[dateKey] ?? [];

        return CalendarDayCell(
          date: date,
          isOutsideMonth: isOutside,
          isToday: isToday,
          workoutCount: workouts.length,
          onTap: () => _showDayDetails(date),
        );
      },
    );
  }

  List<DateTime> _getDaysInGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final prevMonthDays = firstWeekday;
    const totalCells = 42;
    final days = <DateTime>[];

    for (int i = prevMonthDays; i > 0; i--) {
      days.add(firstDayOfMonth.subtract(Duration(days: i)));
    }
    for (int i = 0; i < lastDayOfMonth.day; i++) {
      days.add(firstDayOfMonth.add(Duration(days: i)));
    }
    final remaining = totalCells - days.length;
    for (int i = 1; i <= remaining; i++) {
      days.add(lastDayOfMonth.add(Duration(days: i)));
    }
    return days;
  }
}
