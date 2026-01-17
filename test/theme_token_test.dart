// test/theme_token_test.dart
// Regression test to prevent accidental theme token changes.
// Run with: dart test test/theme_token_test.dart

import 'dart:convert';
import 'dart:io';

void main() {
  // Test: Dark theme tokens are present in design-spec.json
  final f = File('design/design-spec.json');

  if (!f.existsSync()) {
    print('ERROR: design/design-spec.json not found');
    exit(1);
  }

  final content = f.readAsStringSync();
  final json = jsonDecode(content) as Map<String, dynamic>;
  final theme = json['theme'] as Map<String, dynamic>? ?? {};

  // Check background color
  final bg = theme['background'] ?? theme['bg'];
  if (bg != '#0E0E0E') {
    print('FAIL: Expected background "#0E0E0E", got "$bg"');
    exit(1);
  }

  // Check accent color
  final accent = theme['accent'];
  if (accent != '#FC4C02') {
    print('FAIL: Expected accent "#FC4C02", got "$accent"');
    exit(1);
  }

  print('PASS: Dark theme tokens verified');
  print('  - background: $bg');
  print('  - accent: $accent');
}
