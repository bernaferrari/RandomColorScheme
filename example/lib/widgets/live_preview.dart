import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme_model.dart';
import 'studio_controls.dart';

/// Displays one seed's Light and/or Dark theme specimens with smooth,
/// interruptible transitions between `Both`, `Light`, and `Dark`.
class SchemePairRow extends StatefulWidget {
  const SchemePairRow({
    super.key,
    required this.pair,
    required this.brightnessFilter,
    required this.onOpenCode,
  });

  final SchemePair pair;
  final FeedBrightness brightnessFilter;
  final void Function(SchemePair pair, Brightness brightness) onOpenCode;

  @override
  State<SchemePairRow> createState() => _SchemePairRowState();
}

class _SchemePairRowState extends State<SchemePairRow>
    with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 260);

  late final AnimationController _lightController;
  late final AnimationController _darkController;
  late final Animation<double> _lightCurve;
  late final Animation<double> _darkCurve;

  bool get _wantLight => widget.brightnessFilter != FeedBrightness.dark;
  bool get _wantDark => widget.brightnessFilter != FeedBrightness.light;

  @override
  void initState() {
    super.initState();
    _lightController = AnimationController(
      vsync: this,
      duration: _duration,
      value: _wantLight ? 1.0 : 0.0,
    );
    _darkController = AnimationController(
      vsync: this,
      duration: _duration,
      value: _wantDark ? 1.0 : 0.0,
    );
    _lightCurve = CurvedAnimation(
      parent: _lightController,
      curve: kStudioEaseInOut,
    );
    _darkCurve = CurvedAnimation(
      parent: _darkController,
      curve: kStudioEaseInOut,
    );
  }

  @override
  void didUpdateWidget(covariant SchemePairRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brightnessFilter != widget.brightnessFilter) {
      final disableMotion = MediaQuery.disableAnimationsOf(context);
      final targetDuration = disableMotion ? Duration.zero : _duration;
      _lightController.duration = targetDuration;
      _darkController.duration = targetDuration;
      _lightController.animateTo(_wantLight ? 1.0 : 0.0);
      _darkController.animateTo(_wantDark ? 1.0 : 0.0);
    }
  }

  @override
  void dispose() {
    _lightController.dispose();
    _darkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final sideBySide = maxWidth >= 860;
        const gap = 16.0;

        return AnimatedBuilder(
          animation: Listenable.merge([_lightCurve, _darkCurve]),
          builder: (context, _) {
            final l = _lightCurve.value;
            final d = _darkCurve.value;

            final lightCard = _ThemeSpecimenCard(
              pair: widget.pair,
              scheme: widget.pair.light,
              onOpenCode: () =>
                  widget.onOpenCode(widget.pair, Brightness.light),
            );
            final darkCard = _ThemeSpecimenCard(
              pair: widget.pair,
              scheme: widget.pair.dark,
              onOpenCode: () => widget.onOpenCode(widget.pair, Brightness.dark),
            );

            if (!sideBySide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (l > 0.0) _VerticalRevealSlot(factor: l, child: lightCard),
                  if (l > 0.0 && d > 0.0) SizedBox(height: 12 * l * d),
                  if (d > 0.0) _VerticalRevealSlot(factor: d, child: darkCard),
                ],
              );
            }

            final halfWidth = (maxWidth - gap) / 2;
            final activeSum = math.max(1.0, l + d);
            final animatedGap = gap * l * d;
            final available = maxWidth - animatedGap;
            final lightSlotWidth = available * (l / activeSum);
            final darkSlotWidth = available * (d / activeSum);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (l > 0.0)
                  _HorizontalRevealSlot(
                    slotWidth: lightSlotWidth,
                    minLayoutWidth: halfWidth,
                    factor: l,
                    alignment: Alignment.topLeft,
                    child: lightCard,
                  ),
                if (animatedGap > 0.0) SizedBox(width: animatedGap),
                if (d > 0.0)
                  _HorizontalRevealSlot(
                    slotWidth: darkSlotWidth,
                    minLayoutWidth: halfWidth,
                    factor: d,
                    alignment: Alignment.topRight,
                    child: darkCard,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HorizontalRevealSlot extends StatelessWidget {
  const _HorizontalRevealSlot({
    required this.slotWidth,
    required this.minLayoutWidth,
    required this.factor,
    required this.alignment,
    required this.child,
  });

  final double slotWidth;
  final double minLayoutWidth;
  final double factor;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final layoutWidth = math.max(slotWidth, minLayoutWidth);
    final widthFactor = (slotWidth / layoutWidth).clamp(0.0, 1.0);
    final scale = 0.96 + 0.04 * factor;

    return ClipRect(
      child: Align(
        alignment: alignment,
        widthFactor: widthFactor,
        child: SizedBox(
          width: layoutWidth,
          child: Opacity(
            opacity: factor.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalRevealSlot extends StatelessWidget {
  const _VerticalRevealSlot({required this.factor, required this.child});

  final double factor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scale = 0.96 + 0.04 * factor;
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: factor.clamp(0.0, 1.0),
        child: Opacity(
          opacity: factor.clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: child),
        ),
      ),
    );
  }
}

class _ThemeSpecimenCard extends StatelessWidget {
  const _ThemeSpecimenCard({
    required this.pair,
    required this.scheme,
    required this.onOpenCode,
  });

  final SchemePair pair;
  final ColorScheme scheme;
  final VoidCallback onOpenCode;

  @override
  Widget build(BuildContext context) {
    final isDark = scheme.brightness == Brightness.dark;
    final motionDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);

    final canvas = !isDark
        ? scheme.surfaceContainerLow
        : scheme.surfaceContainerLowest;
    final cardSurface = isDark
        ? scheme.surfaceContainer
        : scheme.surfaceContainerLowest;
    final canvasInk = readableInk(canvas);
    final swatches = swatchesFor(scheme);
    final tag = formatVariantName(pair.pick.variant);

    final previewTheme = ThemeData(
      colorScheme: scheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );

    final specimen = switch (pair.seed % 4) {
      0 => _EditorialSpecimen(
        scheme: scheme,
        surface: cardSurface,
        duration: motionDuration,
      ),
      1 => _AudioPlayerSpecimen(
        scheme: scheme,
        surface: cardSurface,
        duration: motionDuration,
      ),
      2 => _AnalyticsSpecimen(
        scheme: scheme,
        surface: cardSurface,
        duration: motionDuration,
      ),
      _ => _TasksSpecimen(
        scheme: scheme,
        surface: cardSurface,
        duration: motionDuration,
      ),
    };

    return Theme(
      data: previewTheme,
      child: Builder(
        builder: (context) {
          return AnimatedContainer(
            duration: motionDuration,
            curve: kStudioEaseOut,
            decoration: BoxDecoration(
              color: canvas,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : StudioPalette.of(context).border,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        constraints: const BoxConstraints(minWidth: 22),
                        height: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: canvasInk.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${pair.seed}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: canvasInk.withValues(alpha: 0.72),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: canvasInk.withValues(alpha: 0.58),
                          ),
                        ),
                      ),
                      _PaletteDots(tokens: swatches, ringColor: canvas),
                      const SizedBox(width: 8),
                      _MiniActionIcon(
                        icon: Icons.code_rounded,
                        tooltip: 'View & copy Dart code',
                        ink: canvasInk,
                        onTap: onOpenCode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  specimen,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Specimen 0: Editorial article & reading card.
class _EditorialSpecimen extends StatelessWidget {
  const _EditorialSpecimen({
    required this.scheme,
    required this.surface,
    required this.duration,
  });

  final ColorScheme scheme;
  final Color surface;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final muted = scheme.onSurface.withValues(alpha: 0.68);
    return _SpecimenShell(
      surface: surface,
      borderColor: scheme.onSurface.withValues(alpha: 0.07),
      duration: duration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PillTag(
                    label: 'Design Journal',
                    bg: scheme.secondaryContainer,
                    fg: scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '4 min read',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Perceptual color systems',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'How tonal surface elevation and balanced accents keep interfaces calm in every lighting mode.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, height: 1.4, color: muted),
              ),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: const Text(
                  'AL',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Alfred · Today',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.bookmark_outline_rounded,
                size: 19,
                color: scheme.primary,
              ),
              const SizedBox(width: 10),
              FilledButton(onPressed: () {}, child: const Text('Read')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Specimen 1: Media / podcast player card with interactive scrubber & play toggle.
class _AudioPlayerSpecimen extends StatefulWidget {
  const _AudioPlayerSpecimen({
    required this.scheme,
    required this.surface,
    required this.duration,
  });

  final ColorScheme scheme;
  final Color surface;
  final Duration duration;

  @override
  State<_AudioPlayerSpecimen> createState() => _AudioPlayerSpecimenState();
}

class _AudioPlayerSpecimenState extends State<_AudioPlayerSpecimen> {
  static const _totalSeconds = 218;
  double _progress = 0.61;
  bool _playing = false;

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    final muted = scheme.onSurface.withValues(alpha: 0.68);
    final elapsed = (_progress * _totalSeconds).round();

    return _SpecimenShell(
      surface: widget.surface,
      borderColor: scheme.onSurface.withValues(alpha: 0.07),
      duration: widget.duration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.graphic_eq_rounded,
                  size: 26,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Midnight Synth',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ambient Sessions · Ep. 14',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PillTag(
                label: 'Hi-Fi',
                bg: scheme.tertiaryContainer,
                fg: scheme.onTertiaryContainer,
              ),
            ],
          ),
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 14,
                  activeTrackColor: scheme.primary,
                  inactiveTrackColor: scheme.secondaryContainer,
                  thumbColor: scheme.primary,
                  overlayColor: scheme.primary.withValues(alpha: 0.12),
                  thumbShape: const HandleThumbShape(),
                  trackShape: const GappedSliderTrackShape(),
                  trackGap: 6,
                  thumbSize: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.pressed)
                        ? const Size(2, 32)
                        : const Size(4, 32),
                  ),
                ),
                child: SizedBox(
                  height: 34,
                  child: Slider(
                    value: _progress,
                    padding: EdgeInsets.zero,
                    onChanged: (value) => setState(() => _progress = value),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(elapsed),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: muted,
                    ),
                  ),
                  Text(
                    _formatTime(_totalSeconds),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.queue_music_rounded, size: 17),
                    label: const Text(
                      'Up next',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _progress = 0.0),
                icon: Icon(Icons.skip_previous_rounded, color: muted),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _playing = !_playing),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: scheme.onPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _progress = 1.0),
                icon: Icon(Icons.skip_next_rounded, color: muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Specimen 2: Weekly analytics & bar chart card.
class _AnalyticsSpecimen extends StatelessWidget {
  const _AnalyticsSpecimen({
    required this.scheme,
    required this.surface,
    required this.duration,
  });

  final ColorScheme scheme;
  final Color surface;
  final Duration duration;

  static const _bars = [
    ('M', 0.48),
    ('T', 0.65),
    ('W', 0.56),
    ('T', 0.96),
    ('F', 0.72),
    ('S', 0.42),
    ('S', 0.80),
  ];

  @override
  Widget build(BuildContext context) {
    final muted = scheme.onSurface.withValues(alpha: 0.68);
    return _SpecimenShell(
      surface: surface,
      borderColor: scheme.onSurface.withValues(alpha: 0.07),
      duration: duration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Weekly focus',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PillTag(
                    label: '+18.4%',
                    bg: scheme.tertiaryContainer,
                    fg: scheme.onTertiaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '24.6 hrs',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'vs 20.8 hrs last week',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 76,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < _bars.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: duration,
                            curve: kStudioEaseOut,
                            height: 52 * _bars[i].$2,
                            decoration: BoxDecoration(
                              color: i == 3
                                  ? scheme.primary
                                  : i == 6
                                  ? scheme.secondary
                                  : scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _bars[i].$1,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: i == 3
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: i == 3 ? scheme.onSurface : muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Specimen 3: Collaborative sprint tasks card.
class _TasksSpecimen extends StatelessWidget {
  const _TasksSpecimen({
    required this.scheme,
    required this.surface,
    required this.duration,
  });

  final ColorScheme scheme;
  final Color surface;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final muted = scheme.onSurface.withValues(alpha: 0.68);
    return _SpecimenShell(
      surface: surface,
      borderColor: scheme.onSurface.withValues(alpha: 0.07),
      duration: duration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Release checklist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  _PillTag(
                    label: '2 / 3',
                    bg: scheme.primaryContainer,
                    fg: scheme.onPrimaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TaskLine(
                title: 'Verify contrast ratios',
                done: true,
                scheme: scheme,
              ),
              const SizedBox(height: 8),
              _TaskLine(
                title: 'Review dark surface tokens',
                done: true,
                scheme: scheme,
              ),
              const SizedBox(height: 8),
              _TaskLine(
                title: 'Ship updated theme',
                done: false,
                badge: 'Today',
                scheme: scheme,
              ),
            ],
          ),
          Row(
            children: [
              _MiniAvatar(
                text: 'BF',
                bg: scheme.primaryContainer,
                fg: scheme.onPrimaryContainer,
              ),
              const SizedBox(width: 4),
              _MiniAvatar(
                text: 'AL',
                bg: scheme.secondaryContainer,
                fg: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '2 collaborators',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ),
              OutlinedButton(onPressed: () {}, child: const Text('Share')),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({
    required this.title,
    required this.done,
    required this.scheme,
    this.badge,
  });

  final String title;
  final bool done;
  final ColorScheme scheme;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: done ? scheme.primary : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: done
                  ? scheme.primary
                  : scheme.secondary.withValues(alpha: 0.7),
              width: 1.5,
            ),
          ),
          child: done
              ? Icon(Icons.check_rounded, size: 12, color: scheme.onPrimary)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              decoration: done ? TextDecoration.lineThrough : null,
              color: done
                  ? scheme.onSurface.withValues(alpha: 0.52)
                  : scheme.onSurface,
              fontWeight: done ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          _PillTag(
            label: badge!,
            bg: scheme.secondaryContainer,
            fg: scheme.onSecondaryContainer,
          ),
        ],
      ],
    );
  }
}

class _SpecimenShell extends StatelessWidget {
  const _SpecimenShell({
    required this.surface,
    required this.borderColor,
    required this.duration,
    required this.child,
  });

  final Color surface;
  final Color borderColor;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: kStudioEaseOut,
      constraints: const BoxConstraints(minHeight: 204),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: IntrinsicHeight(child: child),
    );
  }
}

class _PillTag extends StatelessWidget {
  const _PillTag({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _PaletteDots extends StatefulWidget {
  const _PaletteDots({required this.tokens, required this.ringColor});

  final List<ColorToken> tokens;
  final Color ringColor;

  @override
  State<_PaletteDots> createState() => _PaletteDotsState();
}

class _PaletteDotsState extends State<_PaletteDots> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const size = 16.0;
    const tightStep = 7.5;
    const fannedStep = 18.0;
    final step = _hovered ? fannedStep : tightStep;
    final count = widget.tokens.length;
    final totalWidth = count == 0 ? 0.0 : size + step * (count - 1);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: duration,
        curve: kStudioEaseOut,
        width: totalWidth,
        height: size + 4,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            for (var i = count - 1; i >= 0; i--)
              AnimatedPositioned(
                duration: duration,
                curve: kStudioEaseOut,
                left: i * step,
                top: 2,
                child: _DotCircle(
                  token: widget.tokens[i],
                  ringColor: widget.ringColor,
                  interactive: _hovered,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DotCircle extends StatefulWidget {
  const _DotCircle({
    required this.token,
    required this.ringColor,
    required this.interactive,
  });

  final ColorToken token;
  final Color ringColor;
  final bool interactive;

  @override
  State<_DotCircle> createState() => _DotCircleState();
}

class _DotCircleState extends State<_DotCircle> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hex = encodeHex(widget.token.color);
    final lift = widget.interactive && _hovered;
    final scale = _pressed
        ? 0.92
        : lift
        ? 1.25
        : 1.0;

    return Tooltip(
      message: '${widget.token.label} · $hex',
      waitDuration: const Duration(milliseconds: 180),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: () => copyWithFeedback(
            context,
            hex,
            label: '${widget.token.label} ($hex)',
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: kStudioEaseOut,
            transform: Matrix4.translationValues(0, lift ? -2.0 : 0.0, 0),
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 150),
              curve: kStudioEaseOut,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: widget.token.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.ringColor, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniActionIcon extends StatelessWidget {
  const _MiniActionIcon({
    required this.icon,
    required this.tooltip,
    required this.ink,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: Semantics(
        button: true,
        label: tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: ink.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: ink.withValues(alpha: 0.85)),
            ),
          ),
        ),
      ),
    );
  }
}
