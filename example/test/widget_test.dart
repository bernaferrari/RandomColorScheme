import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:example/main.dart';

void main() {
  Future<void> verifyFeed(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const RandomColorSchemeExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Random Color Scheme'), findsOneWidget);
    expect(find.text('Any variant'), findsOneWidget);
    expect(find.text('Perceptual color systems'), findsWidgets);
    expect(tester.takeException(), isNull);
  }

  testWidgets('renders scrollable feed on desktop without overflow', (
    tester,
  ) async {
    await verifyFeed(tester, const Size(1440, 900));
  });

  testWidgets('renders scrollable feed on mobile without overflow', (
    tester,
  ) async {
    await verifyFeed(tester, const Size(390, 844));
  });

  testWidgets('pinned header stays visible on scroll and toggles dark mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const RandomColorSchemeExampleApp());
    await tester.pumpAndSettle();

    // Scroll down feed; pinned header must remain visible
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Random Color Scheme'), findsOneWidget);
    expect(find.text('Shuffle'), findsOneWidget);

    // Switch variant to Fidelity and back to Any variant (random)
    await tester.tap(find.text('Any variant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fidelity').last);
    await tester.pumpAndSettle();
    expect(find.text('Fidelity'), findsWidgets);

    await tester.tap(find.text('Fidelity').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any variant (random)'));
    await tester.pumpAndSettle();
    expect(find.text('Any variant'), findsOneWidget);

    // Toggle studio dark mode
    await tester.tap(find.byTooltip('Toggle dark mode'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);

    // Animate Both -> Light -> Dark -> Both
    await tester.tap(find.text('Light'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Both'));
    await tester.pumpAndSettle();

    // Open syntax-highlighted code modal on a visible card
    final codeButton = find.byTooltip('View & copy Dart code').last;
    await tester.ensureVisible(codeButton);
    await tester.tap(codeButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('dynamicSchemeVariant:'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
