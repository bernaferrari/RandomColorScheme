import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:random_color_scheme/random_color_scheme.dart';

/// Archival warm-paper and obsidian studio palettes inspired by Chroma Folio.
class StudioPalette {
  const StudioPalette({
    required this.paper,
    required this.surface,
    required this.track,
    required this.activePill,
    required this.border,
    required this.ink,
    required this.inkMuted,
  });

  final Color paper;
  final Color surface;
  final Color track;
  final Color activePill;
  final Color border;
  final Color ink;
  final Color inkMuted;

  static const light = StudioPalette(
    paper: Color(0xFFF6F4EE),
    surface: Color(0xFFFCFAF5),
    track: Color(0xFFECE9E1),
    activePill: Color(0xFFFFFFFF),
    border: Color(0xFFE0DDD4),
    ink: Color(0xFF191918),
    inkMuted: Color(0xFF6B6A66),
  );

  static const dark = StudioPalette(
    paper: Color(0xFF0C0D10),
    surface: Color(0xFF12141A),
    track: Color(0xFF16181F),
    activePill: Color(0xFF292C36),
    border: Color(0xFF262934),
    ink: Color(0xFFF3F1EC),
    inkMuted: Color(0xFF9EA0A8),
  );

  static StudioPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Code block constants.
abstract final class StudioColors {
  static const codeSurface = Color(0xFF141519);
  static const codeInk = Color(0xFFF0EFEA);
}

/// Contrast levels supported by `ColorScheme.fromSeed`.
enum ContrastPreset {
  standard('Std', 0.0),
  medium('Med', 0.5),
  high('High', 1.0);

  const ContrastPreset(this.label, this.value);
  final String label;
  final double value;
}

/// Pairs Light and Dark Material 3 [ColorScheme]s generated from the same seed.
class SchemePair {
  const SchemePair({
    required this.seed,
    required this.pick,
    required this.contrastLevel,
    required this.light,
    required this.dark,
  });

  factory SchemePair.generate({
    required int seed,
    DynamicSchemeVariant? variant,
    required double contrastLevel,
  }) {
    final pick = resolveDynamicSchemeSeed(seed: seed, variant: variant);
    return SchemePair(
      seed: seed,
      pick: pick,
      contrastLevel: contrastLevel,
      light: randomDynamicColorSchemeLight(
        seed: seed,
        variant: pick.variant,
        contrastLevel: contrastLevel,
        shouldPrint: false,
      ),
      dark: randomDynamicColorSchemeDark(
        seed: seed,
        variant: pick.variant,
        contrastLevel: contrastLevel,
        shouldPrint: false,
      ),
    );
  }

  final int seed;
  final DynamicSchemeSeed pick;
  final double contrastLevel;
  final ColorScheme light;
  final ColorScheme dark;
}

/// Describes one color role in a swatch cluster.
class ColorToken {
  const ColorToken({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Returns the 6 key swatches to display for a Material 3 [ColorScheme].
List<ColorToken> swatchesFor(ColorScheme scheme) => [
  ColorToken(label: 'Primary', color: scheme.primary),
  ColorToken(label: 'Primary Container', color: scheme.primaryContainer),
  ColorToken(label: 'Secondary', color: scheme.secondary),
  ColorToken(label: 'Secondary Container', color: scheme.secondaryContainer),
  ColorToken(label: 'Tertiary', color: scheme.tertiary),
  ColorToken(label: 'Surface', color: scheme.surface),
];

/// Encodes [color] as `#RRGGBB`.
String encodeHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// Picks readable black or white ink over [background].
Color readableInk(Color background) =>
    background.computeLuminance() > 0.179 ? Colors.black : Colors.white;

/// Builds the concise one-liner call using `random_color_scheme`.
String buildOneLinerSnippet({
  required SchemePair pair,
  required Brightness brightness,
}) {
  final fn = brightness == Brightness.dark
      ? 'randomDynamicColorSchemeDark'
      : 'randomDynamicColorSchemeLight';
  final args = [
    'seed: ${pair.seed}',
    'variant: DynamicSchemeVariant.${pair.pick.variant.name}',
    if (pair.contrastLevel != 0.0) 'contrastLevel: ${pair.contrastLevel}',
  ].join(', ');
  return '$fn($args)';
}

/// Builds the native `ColorScheme.fromSeed(...)` code snippet.
String buildExportSnippet({
  required SchemePair pair,
  required Brightness brightness,
}) {
  final literal =
      'Color(0x${pair.pick.seedColor.toARGB32().toRadixString(16).padLeft(8, '0')})';
  return [
    'ColorScheme.fromSeed(',
    '  seedColor: $literal,',
    '  brightness: Brightness.${brightness.name},',
    '  dynamicSchemeVariant: DynamicSchemeVariant.${pair.pick.variant.name},',
    if (pair.contrastLevel != 0.0) '  contrastLevel: ${pair.contrastLevel},',
    ')',
  ].join('\n');
}

/// Formats a [DynamicSchemeVariant] camelCase name into a readable label.
String formatVariantName(DynamicSchemeVariant variant) {
  final spaced = variant.name.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (m) => ' ${m.group(1)}',
  );
  return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

/// Copies [value] to the clipboard and shows a quiet floating snackbar.
Future<void> copyWithFeedback(
  BuildContext context,
  String value, {
  String? label,
}) async {
  HapticFeedback.selectionClick();
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted || messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            label != null ? 'Copied $label' : 'Copied $value',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      );
  } on PlatformException {
    if (!context.mounted || messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1400),
          content: Text('Clipboard unavailable'),
        ),
      );
  }
}
