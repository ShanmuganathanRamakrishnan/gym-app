import 'package:flutter/material.dart';
import '../services/measurements_service.dart';
import '../models/measurement.dart';
import '../widgets/measurement_list_item.dart';
import '../theme/gym_theme.dart';
import 'log_measurement_screen.dart';
import 'measurement_trends_screen.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final MeasurementsService _service = MeasurementsService();
  List<Measurement> _measurements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    // Service is already initialized at app startup generally,
    // but safe to ensure it's ready or just get data.
    await _service.init();
    final data = _service.getAll();

    if (mounted) {
      setState(() {
        _measurements = data;
        _loading = false;
      });
    }
  }

  Future<void> _navigateToAdd() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LogMeasurementScreen()),
    );
    _loadMeasurements();
  }

  Future<void> _onItemTap(Measurement m) async {
    // Open in Edit Mode
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LogMeasurementScreen(measurement: m)),
    );
    _loadMeasurements();
  }

  void _navigateToTrends() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MeasurementTrendsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        leading: const BackButton(),
        title: Text('Measurements', style: GymTheme.text.screenTitle),
        actions: [
          // Trends Icon
          IconButton(
            icon: const Icon(Icons.show_chart, color: Colors.white),
            onPressed: _navigateToTrends,
          ),
          // Add Icon
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _navigateToAdd,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent))
          : _measurements.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.accessibility_new_rounded,
              size: 64,
              color: GymTheme.colors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No measurements yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your body progress',
              style: TextStyle(
                color: GymTheme.colors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Primary CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymTheme.colors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '+ Add Measurement',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary CTA (Muted)
            TextButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const LogMeasurementScreen()),
                );
                _loadMeasurements();
              },
              style: TextButton.styleFrom(
                foregroundColor: GymTheme.colors.textMuted,
              ),
              child: const Text('Add Progress Photo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _measurements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final measurement = _measurements[index];
        return MeasurementListItem(
          measurement: measurement,
          onTap: () => _onItemTap(measurement),
        );
      },
    );
  }
}
