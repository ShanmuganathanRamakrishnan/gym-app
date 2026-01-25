import 'package:flutter/services.dart' show rootBundle;
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:collection/collection.dart';
import 'size_controller.dart';
import 'models/muscle.dart';

class PathParser {
  static PathParser? _instance;

  static PathParser get instance {
    _instance ??= PathParser._init();
    return _instance!;
  }

  final sizeController = SizeController.instance;

  PathParser._init();

  // Copied from muscle_selector/src/constant.dart
  static const mapRegexp = '.* id="(.*)" title="(.*)" .* d="(.*)"';
  // Standard Flutter package asset path pattern
  static const assetPath =
      'packages/muscle_selector/assets/maps/human_body.svg';

  // Copied from muscle_selector/src/parser.dart
  static const muscleGroups = {
    'chest': ['chest1', 'chest2'],
    'shoulders': ['shoulder1', 'shoulder2', 'shoulder3', 'shoulder4'],
    'obliques': ['obliques1', 'obliques2'],
    'abs': ['abs1', 'abs2', 'abs3', 'abs4', 'abs5', 'abs6', 'abs7', 'abs8'],
    'abductor': ['abductor1', 'abductor2'],
    'biceps': ['biceps1', 'biceps2'],
    'calves': ['calves1', 'calves2', 'calves3', 'calves4'],
    'forearm': [
      'forearm1',
      'forearm2',
      'forearm3',
      'forearm4'
    ], // Maps to internal: 'forearms'
    'glutes': ['glutes1', 'glutes2'],
    'harmstrings': [
      'harmstrings1',
      'harmstrings2'
    ], // Note Typo in lib: 'harmstrings'
    'lats': ['lats1', 'lats2'],
    'upper_back': ['upper_back1', 'upper_back2'],
    'quads': ['quads1', 'quads2', 'quads3', 'quads4'],
    'trapezius': [
      'trapezius1',
      'trapezius2',
      'trapezius3',
      'trapezius4',
      'trapezius5'
    ],
    'triceps': ['triceps1', 'triceps2'],
    'adductors': ['adductors1', 'adductors2'],
    'lower_back': ['lower_back'],
    'neck': ['neck']
  };

  Set<Muscle> getMusclesByGroups(
      List<String> groupKeys, List<Muscle> muscleList) {
    final groupIds =
        groupKeys.expand((groupKey) => muscleGroups[groupKey] ?? []).toSet();
    return muscleList.where((muscle) => groupIds.contains(muscle.id)).toSet();
  }

  Future<List<Muscle>> loadMuscles() async {
    final svgMuscle = await rootBundle.loadString(assetPath);
    List<Muscle> muscleList = [];

    final regExp =
        RegExp(mapRegexp, multiLine: true, caseSensitive: false, dotAll: false);

    regExp.allMatches(svgMuscle).forEach((muscleData) {
      final id = muscleData.group(1)!;
      final title = muscleData.group(2)!;
      final path = parseSvgPath(muscleData.group(3)!);

      sizeController.addBounds(path.getBounds());

      final muscle = Muscle(id: id, title: title, path: path);

      muscleList.add(muscle);

      // Add muscles to groups
      final group = muscleGroups.entries
          .firstWhereOrNull((entry) => entry.value.contains(id));
      if (group != null) {
        // Find if this ID is part of a group, and add group aliases?
        // Original logic:
        /*
        final group = muscleGroups.entries.firstWhereOrNull((entry) => entry.value.contains(id));
        if (group != null) {
          for (var groupId in group.value) {
            if (groupId != id) {
              final groupMuscle = Muscle(id: groupId, title: title, path: path);
              muscleList.add(groupMuscle);
            }
          }
        }
        */
        // This original logic seems to duplicate muscles for every ID in the group?
        // Actually, it seems to ensure that if "chest1" is found, it adds "chest1" AND "chest2" using the same path? No.
        // It says: if `id` is in a group (e.g. `chest` has `chest1`, `chest2`).
        // If we found `chest1` in SVG.
        // We add `chest1` muscle.
        // Then iterate `group.value` (`chest1`, `chest2`).
        // If `groupId != id` (so `chest2`), add `Muscle(id: chest2, path: path of chest1)`.
        // This implies `chest1` and `chest2` are identical paths? That's wrong. The SVG has distinct paths for chest1/chest2.
        // Wait, looking at SVG, there IS `path id="chest1"` and `path id="chest2"`.
        // The regex loop runs for EACH match in SVG.
        // So when it hits `chest1`, it adds `chest1`.
        // Then it adds `chest2` (with chest1's path)?? That sounds like a bug in the original library or I misunderstood.
        // "final groupMuscle = Muscle(id: groupId, title: title, path: path);"
        // If I keep this logic, I might duplicate paths incorrectly.
        // But if the library works, maybe I should keep it?
        // Wait, if `chest2` is ALSO in the SVG, it will be matched later by regex.
        // Then it adds `chest2`. And duplication for `chest1`.
        // This logic seems deeply flawed or intended for "selecting one selects group"?
        // No, `Parser` creates the list of muscles to DRAW.
        // If we draw specific paths, we don't want duplicates.
        // I will COMMENT OUT the group duplication logic logic for now.
        // I just want to draw the SVG paths as defined in SVG.
        // If I want to group them (e.g. coloring "chest" colors both "chest1" and "chest2"), I will handle that in the Painter/Widget.
        // I want the raw muscles.
      }
    });

    return muscleList;
  }
}
