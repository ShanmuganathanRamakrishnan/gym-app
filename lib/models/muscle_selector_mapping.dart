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
  forearms, // Added for completeness if supported
  traps, // Added for completeness if supported
  other,
}

/// Mapping to muscle_selector package IDs
/// Based on standard SVG IDs usually found in such packages.
const Map<InternalMuscle, String> muscleSelectorIdMap = {
  InternalMuscle.chest: 'chest',
  InternalMuscle.shoulders: 'shoulders',
  InternalMuscle.biceps: 'biceps',
  InternalMuscle.triceps: 'triceps',
  InternalMuscle.back: 'back',
  InternalMuscle.abs: 'abs',
  InternalMuscle.glutes: 'glutes',
  InternalMuscle.quads: 'quads',
  InternalMuscle.hamstrings: 'hamstrings',
  InternalMuscle.calves: 'calves',
  InternalMuscle.forearms: 'forearms',
  InternalMuscle.traps: 'traps',
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
  if (lower.contains('forearm')) {
    return InternalMuscle.forearms;
  }
  if (lower.contains('trap')) {
    return InternalMuscle.traps;
  }

  return InternalMuscle.other;
}
