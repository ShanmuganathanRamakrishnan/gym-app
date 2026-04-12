/// Centralized Muscle Enum for the entire app.
enum InternalMuscle {
  chest,
  shoulders,
  biceps,
  triceps,
  back, // Aggregated back
  abs, // Core/Abs
  glutes,
  quads,
  hamstrings,
  calves,
  forearms,
  traps,
  adductors, // Added
  abductors, // Added
  neck, // Added
  other,
}

/// Canonical mapping definitions for Muscle SVG
class MuscleSvgMap {
  /// Maps the internal enum to the SVG Group ID (key in `svgGroupToPaths`).
  static const Map<InternalMuscle, String> muscleToSvgGroup = {
    InternalMuscle.chest: 'chest',
    InternalMuscle.shoulders: 'shoulders',
    InternalMuscle.biceps: 'biceps',
    InternalMuscle.triceps: 'triceps',
    InternalMuscle.back: 'back', // Logical group, maps to multiple SVG groups?
    // Wait, PathParser used 'back' to check 'lats', 'upper_back', 'lower_back'.
    // We need to define how 'back' enum maps to SVG groups.
    // In the old map: InternalMuscle.back: 'back'.
    // But 'back' is NOT a key in PathParser.muscleGroups.
    // PathParser had 'lats', 'upper_back', 'lower_back'.
    // We should probably map InternalMuscle.back to a LIST of groups or change the structure.
    // For simplicity, let's keep 1:1 where possible, or 1:N.

    // Actually, looking at PathParser logic:
    // It didn't use `muscleSelectorIdMap` for parsing. It used `muscleGroups`.
    // `muscleSelectorIdMap` was used in Heatmap to find the ID to color.
    // The previous map had `InternalMuscle.back: 'back'`.
    // But 'back' key DOES NOT exist in `PathParser.muscleGroups`.
    // This implies `back` wasn't coloring anything? check `MuscleHeatmap`:
    // `final id = muscleSelectorIdMap[muscle]; colorMap[id] = ...`
    // `MusclePainter` checks: `colorMap.containsKey(muscle.id)` OR `colorMap.containsKey(groupEntry.key)`.
    // If we pass 'back' as key, and 'back' is NOT in `muscleGroups`, then `groupEntry` logic fails.
    // Unless there is a 'back' group?
    // PathParser keys: chest, shoulders, obliques, abs, abductor, biceps, calves, forearm, glutes, harmstrings, lats, upper_back, quads, trapezius, triceps, adductors, lower_back, neck.
    // NO 'back'.
    // So `InternalMuscle.back` never lit up the heatmap?
    // It seems so! 'lats', 'upper_back', 'lower_back' are the keys.
    // We need to fix this too.

    InternalMuscle.abs: 'abs',
    InternalMuscle.glutes: 'glutes',
    InternalMuscle.quads: 'quads',
    InternalMuscle.hamstrings: 'hamstrings', // Corrected from harmstrings
    InternalMuscle.calves: 'calves',
    InternalMuscle.forearms: 'forearm',
    InternalMuscle.traps: 'trapezius',
    InternalMuscle.adductors: 'adductors',
    InternalMuscle.abductors: 'abductor',
    InternalMuscle.neck: 'neck',
  };

  /// Maps SVG Group ID -> List of Path IDs (from the SVG file).
  /// This replaces `PathParser.muscleGroups`.
  static const Map<String, List<String>> svgGroupToPaths = {
    'chest': ['chest1', 'chest2'],
    'shoulders': ['shoulder1', 'shoulder2', 'shoulder3', 'shoulder4'],
    'obliques': ['obliques1', 'obliques2'], // Mapped to Abs?
    'abs': ['abs1', 'abs2', 'abs3', 'abs4', 'abs5', 'abs6', 'abs7', 'abs8'],
    'abductor': ['abductor1', 'abductor2'],
    'biceps': ['biceps1', 'biceps2'],
    'calves': ['calves1', 'calves2', 'calves3', 'calves4'],
    'forearm': ['forearm1', 'forearm2', 'forearm3', 'forearm4'],
    'glutes': ['glutes1', 'glutes2'],
    'hamstrings': [
      'harmstrings1',
      'harmstrings2'
    ], // SVG verification will confirm if IDs are misspelled in SVG file itself.
    // Note: The PathParser had 'harmstrings' key AND 'harmstrings1' values.
    // If the SVG itself has 'harmstrings1', we must use that for VALUES, but we can use 'hamstrings' for KEY.
    'lats': ['lats1', 'lats2'],
    'upper_back': ['upper_back1', 'upper_back2'],
    'lower_back': ['lower_back'],
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
    'neck': ['neck'],
  };

  /// Helper to get all relevant SVG keys for a muscle.
  /// Handles the 'Back' case by aggregating sub-groups.
  static List<String> getSvgKeysForMuscle(InternalMuscle muscle) {
    if (muscle == InternalMuscle.back) {
      return ['lats', 'upper_back', 'lower_back'];
    }
    // 'Abs' might want to include 'obliques'?
    if (muscle == InternalMuscle.abs) {
      // Logic decision: Include obliques in Abs?
      // Previously InternalMuscle.abs maps to 'abs'. 'obliques' were ignored.
      // Let's include 'obliques' for better coverage.
      return ['abs', 'obliques'];
    }

    final key = muscleToSvgGroup[muscle];
    return key != null ? [key] : [];
  }
}

/// Initial string parser (migrated from muscle_selector_mapping.dart)
InternalMuscle? parseInternalMuscle(String name) {
  final lower = name.toLowerCase();

  if (lower.contains('chest') || lower.contains('pec')) {
    return InternalMuscle.chest;
  }
  if (lower.contains('shoulder') || lower.contains('delt')) {
    return InternalMuscle.shoulders;
  }
  if (lower.contains('bicep') || lower.contains('curl')) {
    return InternalMuscle.biceps;
  }
  if (lower.contains('tricep') ||
      lower.contains('extension') ||
      lower.contains('pushdown') ||
      lower.contains('skull')) {
    return InternalMuscle.triceps;
  }

  // Refined Back logic
  if (lower.contains('back') ||
      lower.contains('lat') ||
      lower.contains('row') ||
      lower.contains('pull') ||
      lower.contains('chin')) {
    return InternalMuscle.back;
  }

  if (lower.contains('abs') ||
      lower.contains('core') ||
      lower.contains('crunch') ||
      lower.contains('plank') ||
      lower.contains('situp')) {
    return InternalMuscle.abs;
  }
  if (lower.contains('glute') || lower.contains('hip')) {
    return InternalMuscle.glutes;
  }
  if (lower.contains('quad') ||
      lower.contains('squat') ||
      lower.contains('leg press')) {
    return InternalMuscle.quads;
  }
  if (lower.contains('ham') ||
      lower.contains('deadlift') ||
      lower.contains('rdl')) {
    return InternalMuscle.hamstrings;
  }
  if (lower.contains('calf') || lower.contains('calves')) {
    return InternalMuscle.calves;
  }
  if (lower.contains('forearm') || lower.contains('brachioradialis')) {
    return InternalMuscle.forearms;
  }
  if (lower.contains('trap')) {
    return InternalMuscle.traps;
  }
  if (lower.contains('adductor') || lower.contains('inner thigh')) {
    return InternalMuscle.adductors;
  }
  if (lower.contains('abductor') || lower.contains('outer thigh')) {
    return InternalMuscle.abductors;
  }
  if (lower.contains('neck')) {
    return InternalMuscle.neck;
  }

  return InternalMuscle.other;
}
