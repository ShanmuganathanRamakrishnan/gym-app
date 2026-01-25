import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'size_controller.dart';
import 'models/muscle.dart';
import 'path_parser.dart'; // For groups mapping if needed

class MusclePainter extends CustomPainter {
  final Muscle muscle;
  final Map<String, Color>? colorMap; // Map muscle ID (e.g. 'chest') to Color
  final Color? strokeColor;
  final Color? defaultColor; // Color for uncolored muscles

  final sizeController = SizeController.instance;

  double _scale = 1.0;

  MusclePainter({
    required this.muscle,
    this.colorMap,
    this.strokeColor,
    this.defaultColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = strokeColor ?? Colors.white30
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Determine fill color
    Color? fillColor = defaultColor;

    // Check direct ID match (e.g. 'chest1')
    if (colorMap != null) {
      if (colorMap!.containsKey(muscle.id)) {
        fillColor = colorMap![muscle.id];
      } else {
        // Check group match
        // Reverse lookup: find which group 'chest1' belongs to (e.g. 'chest')
        // And check if 'chest' is in colorMap
        final groupEntry = PathParser.muscleGroups.entries
            .firstWhereOrNull((e) => e.value.contains(muscle.id));

        if (groupEntry != null && colorMap!.containsKey(groupEntry.key)) {
          fillColor = colorMap![groupEntry.key];
        }
      }
    }

    final fillPen = Paint()
      ..color = fillColor ?? Colors.transparent
      ..style = PaintingStyle.fill;

    _scale = sizeController.calculateScale(size);
    canvas.scale(_scale);

    if (fillColor != null && fillColor != Colors.transparent) {
      canvas.drawPath(muscle.path, fillPen);
    }

    canvas.drawPath(muscle.path, pen);
  }

  @override
  bool shouldRepaint(covariant MusclePainter oldDelegate) {
    return oldDelegate.colorMap != colorMap ||
        oldDelegate.muscle != muscle ||
        oldDelegate.strokeColor != strokeColor;
  }

  @override
  bool hitTest(Offset position) {
    double inverseScale = sizeController.inverseOfScale(_scale);
    return muscle.path.contains(position.scale(inverseScale, inverseScale));
  }
}
