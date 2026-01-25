import 'package:flutter/material.dart';

class MuscleHeatmap extends StatelessWidget {
  final Map<String, double> muscleSets;
  final Function(String, double)? onMuscleTap;

  const MuscleHeatmap({
    super.key,
    required this.muscleSets,
    this.onMuscleTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.65, // Taller aspect ratio for full body
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapUp: (details) {
              _handleTap(details.localPosition, constraints.biggest);
            },
            child: CustomPaint(
              size: constraints.biggest,
              painter: _BodyHeatmapPainter(muscleSets),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(Offset localPosition, Size size) {
    if (onMuscleTap == null) return;

    // Normalize tap to 100x200 coordinate system

    // Choose smaller scale to maintain aspect ratio logic used in painter
    // Painter usually centers content.
    // Let's replicate painter transform logic:
    final scale = size.height / 200; // fit height
    final offsetX = (size.width - (100 * scale)) / 2;

    // Reverse transform
    final normX = (localPosition.dx - offsetX) / scale;
    final normY = localPosition.dy / scale;

    // Check hit
    final hitMuscle = _normalizeHit(normX, normY);
    if (hitMuscle != null) {
      final count = muscleSets[hitMuscle] ?? 0;
      onMuscleTap!(hitMuscle, count);
    }
  }

  String? _normalizeHit(double x, double y) {
    // Check against regions (Basic Rects)
    // Head
    if (_dist(x, y, 50, 15) < 12) {
      return 'Other';
    } // Head usually not targeted directly but "Neck" maybe? Or just ignore.

    // Shoulders
    if (_dist(x, y, 25, 35) < 12 || _dist(x, y, 75, 35) < 12) {
      return 'Shoulders';
    }

    // Chest
    if (x >= 35 && x <= 65 && y >= 30 && y <= 55) {
      return 'Chest';
    }

    // Arms (Biceps/Triceps combined area for tap)
    if ((x >= 12 && x <= 30 && y >= 45 && y <= 95) ||
        (x >= 70 && x <= 88 && y >= 45 && y <= 95)) {
      return 'Arms';
    }

    // Abs/Core
    if (x >= 38 && x <= 62 && y >= 58 && y <= 95) {
      return 'Abs';
    } // "Core" normalized to Abs

    // Quads (Legs)
    if ((x >= 32 && x <= 48 && y >= 100 && y <= 150) ||
        (x >= 52 && x <= 68 && y >= 100 && y <= 150)) {
      return 'Quads';
    } // "Legs" normalized

    // Calves
    if ((x >= 33 && x <= 47 && y >= 155 && y <= 190) ||
        (x >= 53 && x <= 67 && y >= 155 && y <= 190)) {
      return 'Calves';
    }

    // Lats/Back (Side slivers in front view)
    // Hard to tap in front view, but maybe check outer chest area?
    if ((x >= 28 && x <= 35 && y >= 40 && y <= 80) ||
        (x >= 65 && x <= 72 && y >= 40 && y <= 80)) {
      return 'Back';
    }

    return null;
  }

  double _dist(double x1, double y1, double x2, double y2) {
    return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2); // Squared dist check
  }
}

class _BodyHeatmapPainter extends CustomPainter {
  final Map<String, double> muscleSets;

  _BodyHeatmapPainter(this.muscleSets);

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate system: 0-100 width logic, scaled to fit usage
    // We scale by height to keep proportions fixed 1:2
    final scale = size.height / 200;
    // Center horizontally
    final offsetX = (size.width - (100 * scale)) / 2;

    canvas.translate(offsetX, 0);
    canvas.scale(scale);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF3A3A3C); // Dark grey outline

    Color getColor(String muscle) {
      // Handle normalization mapping
      // Map possible keys to display groups
      double count = 0;
      // Simple exact match or fallback?
      // StatisticsService returns normalized names: Chest, Back, Quads, etc.
      count = muscleSets[muscle] ?? 0;

      // Check merged groups if needed
      if (muscle == 'Arms') {
        count += (muscleSets['Biceps'] ?? 0) +
            (muscleSets['Triceps'] ?? 0) +
            (muscleSets['Forearms'] ?? 0);
      }
      if (muscle == 'Legs') {
        count += (muscleSets['Quads'] ?? 0) +
            (muscleSets['Hamstrings'] ?? 0) +
            (muscleSets['Calves'] ?? 0) +
            (muscleSets['Glutes'] ?? 0);
      }

      if (count == 0) return Colors.transparent;

      const base = Color(0xFFFC4C02);
      if (count < 3) return base.withValues(alpha: 0.3);
      if (count < 6) return base.withValues(alpha: 0.5);
      if (count < 10) return base.withValues(alpha: 0.7);
      return base;
    }

    void drawPart(Path path, String muscle, {bool filled = true}) {
      final color = getColor(muscle);
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;

      if (filled && color != Colors.transparent) {
        canvas.drawPath(path, fillPaint);
      }
      canvas.drawPath(path, outlinePaint);
    }

    // HEAD
    final headPath = Path()..addOval(const Rect.fromLTWH(40, 5, 20, 22));
    drawPart(headPath, 'Other', filled: false); // Head doesn't light up usually

    // EARS/NECK (omitted for simple geo)

    // SHOULDERS (Delt caps)
    final leftDelt = Path()..addOval(const Rect.fromLTWH(18, 28, 16, 16));
    final rightDelt = Path()..addOval(const Rect.fromLTWH(66, 28, 16, 16));
    drawPart(leftDelt, 'Shoulders');
    drawPart(rightDelt, 'Shoulders');

    // CHEST (Pec plates)
    final chest = Path()
      ..moveTo(34, 30)
      ..lineTo(66, 30) // top
      ..lineTo(64, 55)
      ..lineTo(36, 55) // bottom
      ..close();
    drawPart(chest, 'Chest');

    // ABS (Core) - Segmented look
    // Upper abs
    final abs = Path()..addRect(const Rect.fromLTWH(38, 58, 24, 35));
    drawPart(abs, 'Core'); // "Core" maps from "Abs"

    // ARMS (Biceps/Triceps/Forearms specific or General Arms?)
    // Let's draw Upper Arm and Forearm separately but color with 'Arms' or specific
    // Upper Arm Left
    final leftArm = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(15, 45, 14, 28), const Radius.circular(4)));
    // Upper Arm Right
    final rightArm = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(71, 45, 14, 28), const Radius.circular(4)));

    Color leftArmColor = getColor('Biceps');
    if (leftArmColor == Colors.transparent) leftArmColor = getColor('Triceps');
    if (leftArmColor == Colors.transparent) leftArmColor = getColor('Arms');

    // Helper manual draw for specific split if available
    canvas.drawPath(leftArm, Paint()..color = leftArmColor);
    canvas.drawPath(leftArm, outlinePaint);
    canvas.drawPath(rightArm, Paint()..color = leftArmColor);
    canvas.drawPath(rightArm, outlinePaint);

    // Forearms
    final leftFore = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(12, 76, 16, 24), const Radius.circular(3)));
    final rightFore = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(72, 76, 16, 24), const Radius.circular(3)));
    // Color logic
    drawPart(leftFore,
        'Forearms'); // Fallback to Arms handled in getColor logic? No, getColor('Forearms')
    drawPart(rightFore, 'Forearms');

    // LEGS
    // Quads
    final leftQuad = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(32, 100, 16, 42), const Radius.circular(4)));
    final rightQuad = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(52, 100, 16, 42), const Radius.circular(4)));
    drawPart(leftQuad, 'Quads'); // "Quads"
    drawPart(rightQuad, 'Quads');

    // Calves
    final leftCalf = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(33, 145, 14, 32), const Radius.circular(4)));
    final rightCalf = Path()
      ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(53, 145, 14, 32), const Radius.circular(4)));
    drawPart(leftCalf, 'Calves');
    drawPart(rightCalf, 'Calves');

    // TRAPS (Neck side)
    final traps = Path()
      ..moveTo(40, 25)
      ..lineTo(28, 30)
      ..lineTo(72, 30)
      ..lineTo(60, 25)
      ..close();
    // Overlap with neck
    drawPart(traps, 'Back'); // Traps -> Back usually? Or Shoulders.
  }

  @override
  bool shouldRepaint(covariant _BodyHeatmapPainter oldDelegate) {
    return oldDelegate.muscleSets != muscleSets;
  }
}
