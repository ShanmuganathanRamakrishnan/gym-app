import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/muscle_svg_map.dart';
import 'package:gym_app/widgets/vendor/muscle_selector/path_parser.dart'; // import to get asset path constant

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Muscle Data Integrity', () {
    late String svgContent;

    setUpAll(() async {
      // Use rootBundle to load the asset as the app would.
      // We use the path defined in PathParser, which points to the package asset.
      try {
        svgContent = await rootBundle.loadString(PathParser.assetPath);
      } catch (e) {
        // Fallback for test environment if direct load fails (sometimes needs correct bundle)
        // Try loading without package prefix if local, but it is package.
        // If this fails, the test cannot verify integrity.
        throw Exception('Failed to load SVG from ${PathParser.assetPath}: $e');
      }
    });

    test('All InternalMuscle cases (except other) map to a valid SVG Group',
        () {
      for (final muscle in InternalMuscle.values) {
        if (muscle == InternalMuscle.other) continue;

        // Skip 'neck' if we know it's missing in the SVG and we don't want to fail yet,
        // BUT user asked for strict verification.

        final groupKeys = MuscleSvgMap.getSvgKeysForMuscle(muscle);

        expect(groupKeys, isNotEmpty,
            reason: 'Muscle $muscle must map to at least one SVG group key');

        for (final key in groupKeys) {
          expect(MuscleSvgMap.svgGroupToPaths.containsKey(key), isTrue,
              reason:
                  'Muscle $muscle maps to group key "$key", but that key is missing from svgGroupToPaths');
        }
      }
    });

    test('All Mapped SVG Paths exist in the actual SVG file', () {
      // Regex to extract IDs: id="some_id"
      final idRegExp = RegExp(r'id="([^"]+)"');
      final matches = idRegExp.allMatches(svgContent);
      final svgIds = matches.map((m) => m.group(1)).toSet();

      // Check every path ID in our map exists in the SVG
      for (final entry in MuscleSvgMap.svgGroupToPaths.entries) {
        final groupName = entry.key;
        final paths = entry.value;

        for (final pathId in paths) {
          expect(svgIds.contains(pathId), isTrue,
              reason:
                  'Group "$groupName" expects path ID "$pathId", but it was NOT found in the SVG asset');
        }
      }
    });

    test(
        'Critical Muscles (Hamstrings, Forearms, Deadlift mappings) have valid mappings',
        () {
      // Explicitly check the ones requested by user
      final critical = [
        InternalMuscle.hamstrings,
        InternalMuscle.forearms,
        InternalMuscle.adductors,
        // InternalMuscle.abductors, // Check if abductor is present
      ];

      for (final muscle in critical) {
        final keys = MuscleSvgMap.getSvgKeysForMuscle(muscle);
        expect(keys, isNotEmpty, reason: '$muscle should have a mapping');

        for (final key in keys) {
          final paths = MuscleSvgMap.svgGroupToPaths[key];
          expect(paths, isNotEmpty,
              reason: '$muscle -> $key should have paths');
        }
      }
    });
  });
}
