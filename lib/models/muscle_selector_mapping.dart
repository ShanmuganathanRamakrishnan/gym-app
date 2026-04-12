export 'muscle_svg_map.dart';

// Redirect old imports to the new canonical file.
// This ensures we do not break existing code until we update imports.
import 'muscle_svg_map.dart';

// Re-export specific members if needed to maintain API compatibility strictly,
// but 'export' usually covers it.
// muscleSelectorIdMap is now in MuscleSvgMap.muscleToSvgGroup, but naming is different.
// We should provide aliases for backward compatibility during refactor.

const muscleSelectorIdMap = MuscleSvgMap.muscleToSvgGroup;
