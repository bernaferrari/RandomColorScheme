import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:random_color_scheme/random_color_scheme.dart';

void main() {
  test(
    'generated foregrounds meet 4.5:1 contrast across chromatic variants',
    () {
      for (var seed = 0; seed < 128; seed++) {
        for (final isDark in [false, true]) {
          final scheme = randomColorScheme(
            seed: seed,
            isDark: isDark,
            shouldPrint: false,
          );
          for (final (background, foreground) in [
            (scheme.primary, scheme.onPrimary),
            (scheme.primaryContainer, scheme.onPrimaryContainer),
            (scheme.secondary, scheme.onSecondary),
            (scheme.secondaryContainer, scheme.onSecondaryContainer),
            (scheme.surface, scheme.onSurface),
          ]) {
            final first = background.computeLuminance() + 0.05;
            final second = foreground.computeLuminance() + 0.05;
            expect(
              first > second ? first / second : second / first,
              greaterThanOrEqualTo(4.5),
            );
          }
        }
      }
    },
  );

  test('generator is deterministic and respects variant and contrastLevel', () {
    final pickA = resolveDynamicSchemeSeed(seed: 42);
    final pickB = resolveDynamicSchemeSeed(seed: 42);
    expect(pickA.seedColor, pickB.seedColor);
    expect(pickA.variant, pickB.variant);
    expect(chromaticDynamicVariants, contains(pickA.variant));

    expect(
      randomColorSchemeDark(seed: 42, shouldPrint: false),
      randomDynamicColorSchemeDark(seed: 42, shouldPrint: false),
    );
    expect(
      randomColorSchemeLight(seed: 42, shouldPrint: false),
      randomDynamicColorSchemeLight(seed: 42, shouldPrint: false),
    );

    final vibrantLight = randomColorSchemeLight(
      seed: 42,
      variant: DynamicSchemeVariant.vibrant,
      shouldPrint: false,
    );
    final highContrastLight = randomColorSchemeLight(
      seed: 42,
      variant: DynamicSchemeVariant.vibrant,
      contrastLevel: 1.0,
      shouldPrint: false,
    );
    expect(vibrantLight.brightness, Brightness.light);
    expect(highContrastLight.primary, isNot(vibrantLight.primary));
  });
}
