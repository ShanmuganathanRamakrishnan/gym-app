import 'package:flutter/material.dart';
import 'models/muscle.dart';
import 'path_parser.dart';
import 'muscle_painter.dart';
import 'package:collection/collection.dart';

/// A read-only muscle map that supports coloring specific muscles.
/// Forked and modified from muscle_selector's MusclePickerMap.
class MuscleMap extends StatefulWidget {
  final Map<String, Color>? colorMap;
  final Function(String muscleId)? onMuscleTap;
  final double? width;
  final double? height;
  final Color strokeColor;
  final Color defaultColor;

  const MuscleMap({
    super.key,
    this.colorMap,
    this.onMuscleTap,
    this.width,
    this.height,
    this.strokeColor = Colors.white30,
    this.defaultColor =
        Colors.transparent, // Default invisible/transparent fill
  });

  @override
  State<MuscleMap> createState() => _MuscleMapState();
}

class _MuscleMapState extends State<MuscleMap> {
  List<Muscle> _muscles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMuscles();
  }

  Future<void> _loadMuscles() async {
    final list = await PathParser.instance.loadMuscles();
    if (mounted) {
      setState(() {
        _muscles = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: SizedBox.shrink()), // Silent loading
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: _muscles.map((muscle) {
          return Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (widget.onMuscleTap != null) {
                  // If user taps specific part (e.g. chest1), try to resolve group
                  // or just return the ID.
                  // For stats, we often want the group 'chest'.
                  // We can normalize it here or let usage normalize it.
                  // Original parser map allows looking up group.

                  // Let's resolve to group ID if possible, else raw ID
                  String resolvedId = muscle.id;
                  final groupEntry = PathParser.muscleGroups.entries
                      .firstWhereOrNull((e) => e.value.contains(muscle.id));
                  if (groupEntry != null) {
                    resolvedId = groupEntry.key;
                  }

                  widget.onMuscleTap!(resolvedId);
                }
              },
              child: CustomPaint(
                painter: MusclePainter(
                  muscle: muscle,
                  colorMap: widget.colorMap,
                  strokeColor: widget.strokeColor,
                  defaultColor: widget.defaultColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
