library random_color_scheme;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hsluv/hsluvcolor.dart';

const _kPrimary = 'primary';
const _kPrimaryVariant = 'primaryVariant';
const _kSecondary = 'secondary';
const _kSurface = 'surface';
const _kBackground = 'background';

/// Method to generate a random Color Scheme that's either light or dark.
ColorScheme randomColorScheme(
    {int? seed, bool isDark = true, bool shouldPrint = true}) {
  if (isDark) {
    return randomColorSchemeDark(seed: seed, shouldPrint: shouldPrint);
  } else {
    return randomColorSchemeLight(seed: seed, shouldPrint: shouldPrint);
  }
}

/// Generates a random Color Scheme with a dark theme.
/// Properties set: [primary, primaryVariant, secondary, surface, background]
///
/// Input: an optional seed for the Random function.
///
/// Input: an option bool to enable/disable printing to console
/// Output: a random ColorScheme.
ColorScheme randomColorSchemeDark({int? seed, bool shouldPrint = true}) {
  final colors = _getRandomMaterialDark(seed: seed);
  if (shouldPrint) {
    print('''
ColorScheme.dark(
    primary: ${colors[_kPrimary]!.toColor()},
    primaryVariant: ${colors[_kPrimaryVariant]!.toColor()},
    secondary: ${colors[_kSecondary]!.toColor()},
    surface: ${colors[_kSurface]!.toColor()},
    background: ${colors[_kBackground]!.toColor()},
)
''');
  }

  return ColorScheme.dark(
    primary: colors[_kPrimary]!.toColor(),
    primaryVariant: colors[_kPrimaryVariant]!.toColor(),
    secondary: colors[_kSecondary]!.toColor(),
    surface: colors[_kSurface]!.toColor(),
    background: colors[_kBackground]!.toColor(),
  );
}

/// Generates a random Color Scheme with a light theme.
/// Properties set: [primary, primaryVariant, secondary, surface, background]
///
/// Input: an optional seed for the Random function.
///
/// Input: an option bool to enable/disable printing to console
/// Output: a random ColorScheme.
ColorScheme randomColorSchemeLight({int? seed, bool shouldPrint = true}) {
  final colors = _getRandomMaterialLight(seed: seed);

  if (shouldPrint) {
    print('''
ColorScheme.light(
    primary: ${colors[_kPrimary]!.toColor()},
    primaryVariant: ${colors[_kPrimaryVariant]!.toColor()},
    secondary: ${colors[_kSecondary]!.toColor()},
    surface: ${colors[_kSurface]!.toColor()},
    background: ${colors[_kBackground]!.toColor()},
)
''');
  }

  return ColorScheme.light(
    primary: colors[_kPrimary]!.toColor(),
    primaryVariant: colors[_kPrimaryVariant]!.toColor(),
    secondary: colors[_kSecondary]!.toColor(),
    surface: colors[_kSurface]!.toColor(),
    background: colors[_kBackground]!.toColor(),
  );
}

/// Generates a random dark theme that tries to be Material complaint.
///
/// PRIMARY COLOR
/// Reason 1:
/// > "fully saturated brand color is applied to the floating action button"
///
/// Reason 2:
/// Looking at Material Colors in HSV:
/// Primary - H: 267 S: 47 V: 99
/// Secondary - H: 174 S: 99 V: 85
/// OWL - H: 345 S: 54 V: 100
/// We get this range: 50 < S < 100 and V > 80 (currently not being used)
///
/// Looking at Material Colors in HSLuv:
/// Primary - H: 281 S: 97 L: 65
/// Secondary - H: 176 S: 100 L: 79
/// OWL - H: 360 S: 100 L: 67
/// We get this range: S > 90 and 65 < L < 85
///
/// Conclusion:
/// Primary has a saturation of [60-100] and lightness of [65-85].
///
/// PRIMARY VARIANT COLOR
/// Same as Primary, but with lightness = lightness - 10.
///
/// SECONDARY
/// Same saturation and lightness as Primary, but hue is different.
/// The difference from Material's default Primary and Secondary is ~105.
/// Therefore, hue = (hue + 90 + random(90)) % 180.
/// It will have a difference between [90, 180].
///
/// BACKGROUND
/// Has a lightness between [0, 25].
///
/// SURFACE
/// Has a lightness between [0, 30]. However, if:
/// abs(surfaceLightness - backgroundLightness) < 5,
/// just make the surfaceLightness = backgroundLightness + 5.
/// Surface's lightness can be lower than background's lightness.
/// That was a deliberate choice.
///
Map<String, HSLuvColor> _getRandomMaterialDark({int? seed}) {
  final rng = math.Random(seed);

  // avoid too similar values between background and surface.
  final backgroundLightness = rng.nextInt(26);
  var surfaceLightness = rng.nextInt(31);
  if ((surfaceLightness - backgroundLightness).abs() < 5) {
    surfaceLightness = backgroundLightness + 5;
  }

  final primaryHue = rng.nextInt(360);
  final primarySaturation = 60 + rng.nextInt(41).toDouble();
  final primaryLightness = 65 + rng.nextInt(21).toDouble();

  return {
    _kPrimary: HSLuvColor.fromHSL(
      primaryHue.toDouble(),
      primarySaturation,
      primaryLightness.toDouble(),
    ),
    _kPrimaryVariant: HSLuvColor.fromHSL(
      primaryHue.toDouble(),
      primarySaturation,
      primaryLightness - 10.0,
    ),
    _kSecondary: HSLuvColor.fromHSL(
      ((primaryHue + 90 + rng.nextInt(90)) % 360).toDouble(),
      primarySaturation,
      primaryLightness,
    ),
    _kSurface: HSLuvColor.fromHSL(
      rng.nextInt(360).toDouble(),
      rng.nextInt(101).toDouble(),
      surfaceLightness.toDouble(),
    ),
    _kBackground: HSLuvColor.fromHSL(
      rng.nextInt(360).toDouble(),
      rng.nextInt(101).toDouble(),
      backgroundLightness.toDouble(),
    ),
  };
}

/// Generates a random light theme that tries to be Material complaint.
///
/// PRIMARY COLOR
/// Looking at Material Colors in HSV:
/// Primary - H: 265 S: 100 V: 93
/// Secondary - 174 S: 99 L: 85
/// We get this range: S > 90 and V > 80 (currently not being used)
///
/// Looking at Material Colors in HSLuv:
/// Primary - H: 272 S: 100 L: 36
/// Secondary - H: 177 S: 100 L: 79
/// We get this range: S > 90 and 35 < L < 80
///
/// Conclusion:
/// Primary has a saturation of [80-100] and lightness of [25-45].
///
/// PRIMARY VARIANT COLOR
/// Same as Primary, but with lightness = lightness - 10.
///
/// SECONDARY
/// Same saturation and lightness as Primary, but hue is different.
/// The difference from Material's default Primary and Secondary is ~105.
/// Therefore, hue = (hue + 90 + random(90)) % 180.
/// It will have a difference between [90, 180].
///
/// BACKGROUND
/// It is very bright [75-100], saturation stops at 70.
///
/// SURFACE
/// Has a lightness between [25, 45].
///
Map<String, HSLuvColor> _getRandomMaterialLight({int? seed}) {
  final rng = math.Random(seed);

  final primaryHue = rng.nextInt(360);
  final primarySaturation = 80.0 + rng.nextInt(16);
  final primaryLightness = 25 + rng.nextInt(21);

  return {
    _kPrimary: HSLuvColor.fromHSL(
      primaryHue.toDouble(),
      primarySaturation,
      primaryLightness.toDouble(),
    ),
    _kPrimaryVariant: HSLuvColor.fromHSL(
      primaryHue.toDouble(),
      primarySaturation,
      primaryLightness - 10.0,
    ),
    _kSecondary: HSLuvColor.fromHSL(
      ((primaryHue + 90 + rng.nextInt(90)) % 360).toDouble(),
      primarySaturation,
      primaryLightness.toDouble(),
    ),
    _kSurface: HSLuvColor.fromHSL(
      rng.nextInt(360).toDouble(),
      20.0 + rng.nextInt(81),
      primaryLightness + 45.0 + rng.nextInt(56 - primaryLightness),
    ),
    _kBackground: HSLuvColor.fromHSL(
      rng.nextInt(360).toDouble(),
      rng.nextInt(71).toDouble(),
      primaryLightness + 45.0 + rng.nextInt(56 - primaryLightness),
    ),
  };
}
