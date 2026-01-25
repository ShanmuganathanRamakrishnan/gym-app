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

/// Mapping to muscle_selector package IDs
/// Based on standard SVG IDs.
const Map<InternalMuscle, String> muscleSelectorIdMap = {
  InternalMuscle.chest: 'chest',
  InternalMuscle.shoulders: 'shoulders',
  InternalMuscle.biceps: 'biceps',
  InternalMuscle.triceps: 'triceps',
  InternalMuscle.back:
      'back', // Checks 'lats', 'upper_back', 'lower_back' usually managed by parser groups
  InternalMuscle.abs: 'abs',
  InternalMuscle.glutes: 'glutes',
  InternalMuscle.quads: 'quads',
  InternalMuscle.hamstrings:
      'hamstrings', // 'harmstrings' in lib typo, handled by map logic?
  InternalMuscle.calves: 'calves',
  InternalMuscle.forearms: 'forearm', // 'forearm' group in parser
  InternalMuscle.traps: 'trapezius',
  InternalMuscle.adductors: 'adductors',
  InternalMuscle.abductors: 'abductor',
  InternalMuscle.neck: 'neck',
};

/// Reverse lookup or helper if needed for string normalization
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
      lower.contains('pushdown')) {
    return InternalMuscle.triceps;
  }
  if (lower.contains('back') ||
      lower.contains('lat') ||
      lower.contains('row') ||
      lower.contains('pull')) {
    return InternalMuscle.back;
  }
  if (lower.contains('abs') ||
      lower.contains('core') ||
      lower.contains('plank') ||
      (lower.contains('hip') &&
          lower.contains('flexOR')) || // Specific Hip Flexor
      lower.contains('crunch')) {
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
      lower.contains('leg curl') ||
      lower.contains('deadlift')) {
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
