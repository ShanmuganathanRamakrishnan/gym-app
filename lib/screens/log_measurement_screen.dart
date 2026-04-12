import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/measurement.dart';
import '../services/measurements_service.dart';
import '../theme/gym_theme.dart';
import '../widgets/progress_photo_picker.dart';

class LogMeasurementScreen extends StatefulWidget {
  final Measurement? measurement; // If null, create new

  const LogMeasurementScreen({super.key, this.measurement});

  @override
  State<LogMeasurementScreen> createState() => _LogMeasurementScreenState();
}

class _LogMeasurementScreenState extends State<LogMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final MeasurementsService _service = MeasurementsService();

  // State
  late DateTime _date;
  List<String> _photoPaths = [];
  bool _useMetric = true; // Kg/Cm vs Lb/In

  // Controllers
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _waistController = TextEditingController();
  // ... Add others as needed. For MVP, focusing on key ones for brevity but will support all in structure

  @override
  void initState() {
    super.initState();
    final m = widget.measurement;
    _date = m?.date ?? DateTime.now();
    _photoPaths = m != null ? List.from(m.photos) : [];

    // Initialize values (Converting from Canonical if needed)
    // Default to Metric for now or User Preds later
    if (m != null) {
      if (m.metrics.weightKg != null) {
        _weightController.text = m.metrics.weightKg.toString();
      }
      if (m.metrics.bodyFatPercent != null) {
        _bodyFatController.text = m.metrics.bodyFatPercent.toString();
      }
      if (m.metrics.waistCm != null) {
        _waistController.text = m.metrics.waistCm.toString();
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // UI Layer Conversion: Inputs may be Imperial, but WE MUST SAVE CANONICAL (Kg/Cm)
    // This ensures data integrity across the app.
    double? weight = double.tryParse(_weightController.text);
    double? bodyFat = double.tryParse(_bodyFatController.text);
    double? waist = double.tryParse(_waistController.text);

    if (!_useMetric) {
      if (weight != null) {
        weight = _service.lbToKg(weight);
      }
      if (waist != null) {
        waist = _service.inToCm(waist);
      }
    }

    // Construct Model
    final metrics = MeasurementMetrics(
      weightKg: weight,
      bodyFatPercent: bodyFat,
      waistCm: waist,
      // ... Add others
    );

    final measurement = Measurement(
      id: widget.measurement?.id, // Keep ID if editing
      date: _date,
      metrics: metrics,
      photos: _photoPaths,
      createdAt: widget.measurement?.createdAt, // Preserve creation time
    );

    await _service.save(measurement);

    if (mounted) {
      Navigator.pop(context, true); // Signal refresh
    }
  }

  void _onPhotoAdded(String path) {
    setState(() {
      _photoPaths.add(path);
    });
  }

  void _onPhotoRemoved(String path) {
    setState(() {
      _photoPaths.remove(path);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: GymTheme.colors.accent,
              onPrimary: Colors.white,
              surface: GymTheme.colors.surface,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: GymTheme.colors.background,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _toggleUnits() {
    setState(() {
      _useMetric = !_useMetric;
      // Convert current values in fields for UX?
      // Yes, if user typed 100 kg then switches to lb, show 220 lb.
      // This is complex. For simple toggle, maybe just clear or reinterpret?
      // Better: Recalculate displayed values based on stored canonical?
      // Wait, if I'm typing, I haven't stored it yet.
      // Simple approach: Toggle changes the HEADER label (Kg <-> Lb),
      // but value remains what user typed? No, that's dangerous (100kg -> 100lb).
      // Let's implement conversion logic.
      if (_weightController.text.isNotEmpty) {
        final val = double.tryParse(_weightController.text);
        if (val != null) {
          _weightController.text = _useMetric
              ? _service.lbToKg(val).toStringAsFixed(1) // Lb -> Kg
              : _service.kgToLb(val).toStringAsFixed(1); // Kg -> Lb
        }
      }
      if (_waistController.text.isNotEmpty) {
        final val = double.tryParse(_waistController.text);
        if (val != null) {
          _waistController.text = _useMetric
              ? _service.inToCm(val).toStringAsFixed(1)
              : _service.cmToIn(val).toStringAsFixed(1);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.measurement != null;

    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        leading: const CloseButton(),
        title: Text(isEditing ? 'Edit Entry' : 'New Entry',
            style: GymTheme.text.screenTitle),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save',
                style: TextStyle(
                    color: GymTheme.colors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date Picker Row
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: GymTheme.colors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date',
                        style: TextStyle(
                            color: GymTheme.colors.textSecondary,
                            fontSize: 16)),
                    Text(
                      DateFormat.yMMMd().format(_date),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Photos Section
            Text('Progress Photos', style: GymTheme.text.sectionTitle),
            const SizedBox(height: 12),
            ProgressPhotoPicker(
              photoPaths: _photoPaths,
              onPhotoAdded: _onPhotoAdded,
              onPhotoRemoved: _onPhotoRemoved,
            ), // Max capped handled inside widget logic via UI but here we pass all

            const SizedBox(height: 24),

            // Metrics Section Header + Unit Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Metrics', style: GymTheme.text.sectionTitle),
                GestureDetector(
                  onTap: _toggleUnits,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: GymTheme.colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _useMetric ? 'Metric (kg, cm)' : 'Imperial (lb, in)',
                      style: TextStyle(
                          color: GymTheme.colors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Numeric Fields
            _buildNumberField(
              label: 'Weight',
              controller: _weightController,
              unit: _useMetric ? 'kg' : 'lb',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: 'Body Fat',
              controller: _bodyFatController,
              unit: '%',
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: 'Waist',
              controller: _waistController,
              unit: _useMetric ? 'cm' : 'in',
            ),

            const SizedBox(height: 32),

            if (isEditing)
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Confirm Delete Code
                    _showDeleteDialog();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete Entry',
                      style: TextStyle(color: Colors.red)),
                ),
              ),

            const SizedBox(height: 32), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(
      {required String label,
      required TextEditingController controller,
      required String unit}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '-',
                hintStyle: TextStyle(color: GymTheme.colors.textMuted),
                suffixText: ' $unit',
                suffixStyle: TextStyle(
                    color: GymTheme.colors.textSecondary, fontSize: 14),
              ),
              validator: (val) {
                if (val != null &&
                    val.isNotEmpty &&
                    double.tryParse(val) == null) {
                  return 'Invalid';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              backgroundColor: GymTheme.colors.surface,
              title: const Text('Delete Entry?',
                  style: TextStyle(color: Colors.white)),
              content: const Text('This action cannot be undone.',
                  style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext); // Close dialog
                    await _service.delete(widget.measurement!.id);
                    if (mounted) {
                      Navigator.pop(context,
                          true); // Close screen & refresh using Screen context
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ));
  }
}
