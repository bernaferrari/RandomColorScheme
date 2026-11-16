import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'theme_model.dart';
import 'widgets/dart_code_view.dart';
import 'widgets/live_preview.dart';
import 'widgets/studio_controls.dart';

void main() => runApp(const RandomColorSchemeExampleApp());

class RandomColorSchemeExampleApp extends StatefulWidget {
  const RandomColorSchemeExampleApp({super.key});

  @override
  State<RandomColorSchemeExampleApp> createState() =>
      _RandomColorSchemeExampleAppState();
}

class _RandomColorSchemeExampleAppState
    extends State<RandomColorSchemeExampleApp> {
  bool _studioDark = false;

  ThemeData _buildStudioTheme(Brightness brightness, StudioPalette palette) {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.ink,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.neutral,
      ),
      scaffoldBackgroundColor: palette.paper,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Color Scheme',
      debugShowCheckedModeBanner: false,
      themeMode: _studioDark ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 220),
      themeAnimationCurve: kStudioEaseOut,
      theme: _buildStudioTheme(Brightness.light, StudioPalette.light),
      darkTheme: _buildStudioTheme(Brightness.dark, StudioPalette.dark),
      home: PaletteFeedHome(
        isDarkMode: _studioDark,
        onToggleDarkMode: () => setState(() => _studioDark = !_studioDark),
      ),
    );
  }
}

class PaletteFeedHome extends StatefulWidget {
  const PaletteFeedHome({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  @override
  State<PaletteFeedHome> createState() => _PaletteFeedHomeState();
}

class _PaletteFeedHomeState extends State<PaletteFeedHome> {
  static const _pageSize = 16;

  final _rng = math.Random();
  final _scrollController = ScrollController();

  int _startSeed = 0;
  int _count = _pageSize;
  DynamicSchemeVariant? _selectedVariant;
  ContrastPreset _contrast = ContrastPreset.standard;
  FeedBrightness _brightnessFilter = FeedBrightness.both;

  late List<SchemePair> _pairs = _buildPairs();

  List<SchemePair> _buildPairs() => [
    for (var i = 0; i < _count; i++)
      SchemePair.generate(
        seed: _startSeed + i,
        variant: _selectedVariant,
        contrastLevel: _contrast.value,
      ),
  ];

  void _rebuildPairs() {
    setState(() => _pairs = _buildPairs());
  }

  void _shuffle() {
    setState(() {
      _startSeed = _rng.nextInt(9000) + 10;
      _count = _pageSize;
      _pairs = _buildPairs();
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: kStudioEaseOut,
      );
    }
  }

  void _loadMore() {
    setState(() {
      final previous = _count;
      _count += _pageSize;
      _pairs = [
        ..._pairs,
        for (var i = previous; i < _count; i++)
          SchemePair.generate(
            seed: _startSeed + i,
            variant: _selectedVariant,
            contrastLevel: _contrast.value,
          ),
      ];
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openCodeDialog(SchemePair pair, Brightness initialBrightness) {
    var tab = initialBrightness == Brightness.dark ? 1 : 0;
    return showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final palette = StudioPalette.of(context);
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final snippet = switch (tab) {
            0 => buildExportSnippet(pair: pair, brightness: Brightness.light),
            1 => buildExportSnippet(pair: pair, brightness: Brightness.dark),
            _ =>
              '${buildOneLinerSnippet(pair: pair, brightness: Brightness.light)}\n\n${buildOneLinerSnippet(pair: pair, brightness: Brightness.dark)}',
          };

          return AlertDialog(
            backgroundColor: palette.surface,
            title: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  'Seed #${pair.seed}',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: palette.ink,
                  ),
                ),
                StudioPillSelector<int>(
                  value: tab,
                  options: const [
                    (value: 0, label: 'Light'),
                    (value: 1, label: 'Dark'),
                    (value: 2, label: 'One-liner'),
                  ],
                  onChanged: (next) => setState(() => tab = next),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(child: DartCodeView(code: snippet)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: palette.ink,
                  foregroundColor: isDark ? palette.paper : Colors.white,
                ),
                onPressed: () =>
                    copyWithFeedback(context, snippet, label: 'Dart snippet'),
                icon: const Icon(Icons.copy_rounded, size: 15),
                label: const Text('Copy'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showGuideDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final palette = StudioPalette.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: palette.surface,
          title: Text(
            'How it works',
            style: TextStyle(
              fontFamily: 'Instrument Serif',
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: palette.ink,
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GuideRow(
                    title: 'Material 3 Dynamic Schemes',
                    body: 'Samples vibrant seeds and pairs them with chromatic DynamicSchemeVariant presets for full Material 3 tonal cohesion.',
                  ),
                  _GuideRow(
                    title: 'Scroll & inspect',
                    body: 'Scroll through generated Light and Dark pairs. Hover or tap the color dot cluster on any card to fan out and copy hex values.',
                  ),
                  _GuideRow(
                    title: 'Ready-to-paste Dart',
                    body: 'Tap the code icon on any card to copy a clean ColorScheme.fromSeed(...) snippet straight into your app.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: palette.ink,
                foregroundColor: isDark ? palette.paper : Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, limits) {
            final compact = limits.maxWidth < 680;
            final horizontal = compact ? 16.0 : 28.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        compact ? 12 : 16,
                        horizontal,
                        12,
                      ),
                      child: StudioTopBar(
                        selectedVariant: _selectedVariant,
                        contrast: _contrast,
                        brightnessFilter: _brightnessFilter,
                        isDarkMode: widget.isDarkMode,
                        onVariantChanged: (value) {
                          _selectedVariant = value;
                          _rebuildPairs();
                        },
                        onContrastChanged: (value) {
                          _contrast = value;
                          _rebuildPairs();
                        },
                        onBrightnessChanged: (value) =>
                            setState(() => _brightnessFilter = value),
                        onToggleDarkMode: widget.onToggleDarkMode,
                        onShuffle: _shuffle,
                        onShowGuide: _showGuideDialog,
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: palette.border),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          16,
                          horizontal,
                          36,
                        ),
                        itemCount: _pairs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _pairs.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Center(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: palette.ink,
                                    side: BorderSide(color: palette.border),
                                    backgroundColor: palette.surface,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _loadMore,
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Load 16 more palettes'),
                                ),
                              ),
                            );
                          }

                          final pair = _pairs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SchemePairRow(
                              pair: pair,
                              brightnessFilter: _brightnessFilter,
                              onOpenCode: _openCodeDialog,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, color: palette.ink),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: palette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
