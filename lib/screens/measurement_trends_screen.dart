import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/measurement.dart';
import '../services/measurements_service.dart';
import '../theme/gym_theme.dart';
import '../widgets/metric_chart.dart';

class MeasurementTrendsScreen extends StatefulWidget {
  const MeasurementTrendsScreen({super.key});

  @override
  State<MeasurementTrendsScreen> createState() =>
      _MeasurementTrendsScreenState();
}

class _MeasurementTrendsScreenState extends State<MeasurementTrendsScreen> {
  final MeasurementsService _service = MeasurementsService();
  List<Measurement> _allMeasurements = [];

  // Selection State
  MeasurementMetric _selectedMetric = MeasurementMetric.weightKg;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _service.init();
    final data = _service.getAll();
    // Sort oldest to newest for Chart logic (Chart usually likes X asc)
    // But Service returns newest first (desc).
    // Let's keep separate list for chart if needed.

    if (mounted) {
      setState(() {
        _allMeasurements = data;
        _loading = false;
      });
    }
  }

  // Helper to get friendly name
  String _getMetricName(MeasurementMetric m) {
    switch (m) {
      case MeasurementMetric.weightKg:
        return 'Body Weight';
      case MeasurementMetric.bodyFatPercent:
        return 'Body Fat %';
      case MeasurementMetric.waistCm:
        return 'Waist';
      // Add others...
      default:
        return m.name; // Fallback
    }
  }

  String _getUnit(MeasurementMetric m) {
    // Ideally this comes from User Preferences + Service Helper
    // For MVP, assuming Canonical (Kg/Cm/%)
    switch (m) {
      case MeasurementMetric.weightKg:
        return 'kg';
      case MeasurementMetric.bodyFatPercent:
        return '%';
      case MeasurementMetric.waistCm:
        return 'cm';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black, // GymTheme.background
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Filter measurements that have data for selected metric
    final validData = _allMeasurements
        .where((m) => m.metrics.getValue(_selectedMetric) != null)
        .toList();

    // Sort for Chart: Oldest -> Newest
    final chartData = List<Measurement>.from(validData)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Sort for List: Newest -> Oldest
    final listData = List<Measurement>.from(validData)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Current Stats
    final currentVal = listData.isNotEmpty
        ? listData.first.metrics.getValue(_selectedMetric)
        : null;
    final prevVal = listData.length > 1
        ? listData[1].metrics.getValue(_selectedMetric)
        : null;

    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        leading: const BackButton(),
        title: const Text(
            'Trends'), // Or a Dropdown here? Hevy puts Title then Selector below or in Title
      ),
      body: Column(
        children: [
          // 1. Metric Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: GymTheme.colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MeasurementMetric>(
                  value: _selectedMetric,
                  dropdownColor: GymTheme.colors.surface,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: [
                    MeasurementMetric.weightKg,
                    MeasurementMetric.bodyFatPercent,
                    MeasurementMetric.waistCm,
                    // Limit dropdown to implemented MVP metrics
                  ].map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(
                        _getMetricName(m),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMetric = val);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 2. Stats Summary
          if (currentVal != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentVal.toStringAsFixed(1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getUnit(_selectedMetric),
                    style: TextStyle(
                        color: GymTheme.colors.textSecondary, fontSize: 16),
                  ),
                  const Spacer(),
                  if (prevVal != null) _buildDelta(currentVal, prevVal),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // 3. Chart
          SizedBox(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 16, left: 0), // FlChart needs padding adjustments
              child: MetricChart(
                data: chartData,
                metric: _selectedMetric,
                unit: _getUnit(_selectedMetric),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 4. History List
          Expanded(
            child: Container(
              color: GymTheme.colors.surface,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: listData.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final m = listData[index];
                  final val = m.metrics.getValue(_selectedMetric);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMd().format(m.date),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        '${val?.toStringAsFixed(1)} ${_getUnit(_selectedMetric)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDelta(double current, double prev) {
    final diff = current - prev;
    final isPositive = diff > 0;
    // Wait. "Green if lost" is true for weight/fat, false for muscle.
    // Logic needs context. For MVP, just show neutral or simple direction.
    // Let's use Grey for now to avoid confusion, or Green for "Change" if user decides.
    // Hevy uses Red/Green based on goal but that's complex.
    // Let's just use Text colors.

    return Row(
      children: [
        Icon(
          isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: GymTheme.colors.textSecondary,
        ),
        Text(
          '${diff.abs().toStringAsFixed(1)} ${_getUnit(_selectedMetric)}',
          style: TextStyle(color: GymTheme.colors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}
