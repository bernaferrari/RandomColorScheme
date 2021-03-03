import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:random_color_scheme/random_color_scheme.dart';

void main() {
  test('test simple dark scenario', () {
    final colorScheme = randomColorSchemeDark(seed: 0);
    expect(colorScheme.primary, Color(0xff89b9ee));
    expect(colorScheme.primaryVariant, Color(0xff54a0e2));
    expect(colorScheme.secondary, Color(0xfff1a28c));
    expect(colorScheme.secondaryVariant, Color(0xffee7a4b));
    expect(colorScheme.surface, Color(0xff0e0000));
    expect(colorScheme.background, Color(0xff2a4024));

    // unchanged
    expect(colorScheme.onPrimary, Color(0xff000000));
    expect(colorScheme.onBackground, Color(0xffffffff));
    expect(colorScheme.onSurface, Color(0xffffffff));
  });

  test('test simple light scenario', () {
    final colorScheme = randomColorSchemeLight(seed: 0);
    expect(colorScheme.primary, Color(0xff2c589f));
    expect(colorScheme.primaryVariant, Color(0xff1f4178));
    expect(colorScheme.secondary, Color(0xff6a5723));
    expect(colorScheme.secondaryVariant, Color(0xff4f4017));
    expect(colorScheme.surface, Color(0xfffbf4f5));
    expect(colorScheme.background, Color(0xfffeffff));

    // unchanged
    expect(colorScheme.onPrimary, Color(0xffffffff));
    expect(colorScheme.onBackground, Color(0xff000000));
    expect(colorScheme.onSurface, Color(0xff000000));
  });
}
