library random_color_scheme;

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Chromatic [DynamicSchemeVariant] presets used when sampling random M3 themes.
const List<DynamicSchemeVariant> chromaticDynamicVariants = [
  DynamicSchemeVariant.tonalSpot,
  DynamicSchemeVariant.fidelity,
  DynamicSchemeVariant.vibrant,
  DynamicSchemeVariant.expressive,
  DynamicSchemeVariant.content,
  DynamicSchemeVariant.rainbow,
  DynamicSchemeVariant.fruitSalad,
];

/// Seed color and [DynamicSchemeVariant] picked for a Material 3 scheme.
class DynamicSchemeSeed {
  /// Creates a [DynamicSchemeSeed] holding a [seedColor] and [variant].
  const DynamicSchemeSeed({required this.seedColor, required this.variant});

  /// Vibrant seed color sampled in HSL space.
  final Color seedColor;

  /// Selected Material 3 dynamic scheme variant.
  final DynamicSchemeVariant variant;
}

/// Deterministically resolves a vibrant [seedColor] and
/// [DynamicSchemeVariant] from [seed].
///
/// When [variant] is omitted, picks uniformly from [chromaticDynamicVariants]
/// so random themes remain colorful rather than grayscale.
DynamicSchemeSeed resolveDynamicSchemeSeed({
  int? seed,
  DynamicSchemeVariant? variant,
}) {
  final rng = math.Random(seed);
  final hue = rng.nextInt(360).toDouble();
  final saturation = 0.65 + rng.nextInt(36) / 100.0;
  final lightness = 0.42 + rng.nextInt(28) / 100.0;
  final seedColor = HSLColor.fromAHSL(
    1.0,
    hue,
    saturation,
    lightness,
  ).toColor();
  final resolvedVariant =
      variant ??
      chromaticDynamicVariants[rng.nextInt(chromaticDynamicVariants.length)];
  return DynamicSchemeSeed(seedColor: seedColor, variant: resolvedVariant);
}

/// Generates a Material 3 [ColorScheme] using [ColorScheme.fromSeed] with a
/// vibrant sampled seed color and [DynamicSchemeVariant].
///
/// Pass [seed] to reproduce the same scheme. When [variant] is omitted, picks
/// uniformly from [chromaticDynamicVariants].
ColorScheme randomColorScheme({
  int? seed,
  bool isDark = true,
  DynamicSchemeVariant? variant,
  double contrastLevel = 0.0,
  bool shouldPrint = true,
}) {
  final pick = resolveDynamicSchemeSeed(seed: seed, variant: variant);
  final brightness = isDark ? Brightness.dark : Brightness.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: pick.seedColor,
    brightness: brightness,
    dynamicSchemeVariant: pick.variant,
    contrastLevel: contrastLevel,
  );

  if (shouldPrint) {
    final literal =
        'Color(0x${pick.seedColor.toARGB32().toRadixString(16).padLeft(8, '0')})';
    final contrastLine = contrastLevel == 0.0
        ? ''
        : '\n  contrastLevel: $contrastLevel,';
    debugPrint(
      [
        'ColorScheme.fromSeed(',
        '  seedColor: $literal,',
        '  brightness: Brightness.${brightness.name},',
        '  dynamicSchemeVariant: DynamicSchemeVariant.${pick.variant.name},$contrastLine',
        ')',
      ].join('\n'),
    );
  }
  return scheme;
}

/// Generates a dark Material 3 [ColorScheme].
ColorScheme randomColorSchemeDark({
  int? seed,
  DynamicSchemeVariant? variant,
  double contrastLevel = 0.0,
  bool shouldPrint = true,
}) => randomColorScheme(
  seed: seed,
  isDark: true,
  variant: variant,
  contrastLevel: contrastLevel,
  shouldPrint: shouldPrint,
);

/// Generates a light Material 3 [ColorScheme].
ColorScheme randomColorSchemeLight({
  int? seed,
  DynamicSchemeVariant? variant,
  double contrastLevel = 0.0,
  bool shouldPrint = true,
}) => randomColorScheme(
  seed: seed,
  isDark: false,
  variant: variant,
  contrastLevel: contrastLevel,
  shouldPrint: shouldPrint,
);

/// Alias for [randomColorScheme].
ColorScheme randomDynamicColorScheme({
  int? seed,
  bool isDark = true,
  DynamicSchemeVariant? variant,
  double contrastLevel = 0.0,
  bool shouldPrint = true,
}) => randomColorScheme(
  seed: seed,
  isDark: isDark,
  variant: variant,
  contrastLevel: contrastLevel,
  shouldPrint: shouldPrint,
);

/// Alias for [randomColorSchemeDark].
ColorScheme randomDynamicColorSchemeDark({
  int? seed,
  DynamicSchemeVariant? variant,
  double contrastLevel = 0.0,
  bool shouldPrint = true,
}) => randomColorSchemeDark(
  seed: seed,
  variant: variant,
  contrastLevel: contrastLevel,
  shouldPrint: shouldPrint,
);

/// Alias for [randomColorSchemeLight].
ColorScheme randomDynamicColorSchemeLight({
  int? seed,
  DynamicSchemeVariant? variant,
  double contrastLevel = 0.0,
  bool shouldPrint = true,
}) => randomColorSchemeLight(
  seed: seed,
  variant: variant,
  contrastLevel: contrastLevel,
  shouldPrint: shouldPrint,
);
