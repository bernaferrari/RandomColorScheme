import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme_model.dart';

/// Shared snappy ease-out and ease-in-out curves for UI transitions.
const kStudioEaseOut = Cubic(0.23, 1.0, 0.32, 1.0);
const kStudioEaseInOut = Cubic(0.77, 0.0, 0.175, 1.0);

/// Filter options for which brightness modes appear in the scrollable feed.
enum FeedBrightness {
  both('Both'),
  light('Light'),
  dark('Dark');

  const FeedBrightness(this.label);
  final String label;
}

/// Top app bar (title + Shuffle / Dark Mode / Help / Source) with
/// variant, contrast, and brightness filter pills cleanly underneath.
class StudioTopBar extends StatelessWidget {
  const StudioTopBar({
    super.key,
    required this.selectedVariant,
    required this.contrast,
    required this.brightnessFilter,
    required this.isDarkMode,
    required this.onVariantChanged,
    required this.onContrastChanged,
    required this.onBrightnessChanged,
    required this.onToggleDarkMode,
    required this.onShuffle,
    required this.onShowGuide,
  });

  final DynamicSchemeVariant? selectedVariant;
  final ContrastPreset contrast;
  final FeedBrightness brightnessFilter;
  final bool isDarkMode;
  final ValueChanged<DynamicSchemeVariant?> onVariantChanged;
  final ValueChanged<ContrastPreset> onContrastChanged;
  final ValueChanged<FeedBrightness> onBrightnessChanged;
  final VoidCallback onToggleDarkMode;
  final VoidCallback onShuffle;
  final VoidCallback onShowGuide;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);

    final titleGroup = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StudioIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'App demos',
          onTap: () => launchUrl(
            Uri.https('bernaferrari.github.io', '/'),
            webOnlyWindowName: '_self',
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Semantics(
            header: true,
            child: Text(
              'Random Color Scheme',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Instrument Serif',
                fontSize: 30,
                fontWeight: FontWeight.w400,
                height: 1.0,
                letterSpacing: -0.4,
                color: palette.ink,
              ),
            ),
          ),
        ),
      ],
    );

    final topRightActions = Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        StudioIconButton(
          icon: Icons.help_outline_rounded,
          tooltip: 'How it works',
          onTap: onShowGuide,
        ),
        StudioIconButton(
          icon: isDarkMode
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          tooltip: 'Toggle dark mode',
          onTap: onToggleDarkMode,
        ),
        StudioIconButton(
          tooltip: 'GitHub source',
          onTap: () => launchUrl(
            Uri.https('github.com', '/bernaferrari/RandomColorScheme'),
          ),
          iconBuilder: (color) => _GitHubMark(color: color, size: 17),
        ),
      ],
    );

    final filterPills = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _VariantMenuPill(value: selectedVariant, onChanged: onVariantChanged),
        StudioPillSelector<ContrastPreset>(
          value: contrast,
          options: [
            for (final item in ContrastPreset.values)
              (value: item, label: item.label),
          ],
          onChanged: onContrastChanged,
        ),
        StudioPillSelector<FeedBrightness>(
          value: brightnessFilter,
          options: [
            for (final item in FeedBrightness.values)
              (value: item, label: item.label),
          ],
          onChanged: onBrightnessChanged,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 560) {
              return Row(
                children: [
                  Expanded(child: titleGroup),
                  const SizedBox(width: 12),
                  topRightActions,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleGroup,
                const SizedBox(height: 10),
                topRightActions,
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 560) {
              return Row(
                children: [
                  Expanded(child: filterPills),
                  const SizedBox(width: 12),
                  _ShufflePillButton(onTap: onShuffle),
                ],
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                filterPills,
                _ShufflePillButton(onTap: onShuffle),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ShufflePillButton extends StatefulWidget {
  const _ShufflePillButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ShufflePillButton> createState() => _ShufflePillButtonState();
}

class _ShufflePillButtonState extends State<_ShufflePillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = palette.ink;
    final fg = isDark ? palette.paper : Colors.white;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: kStudioEaseOut,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shuffle_rounded, size: 15, color: fg),
                const SizedBox(width: 6),
                Text(
                  'Shuffle',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VariantMenuPill extends StatelessWidget {
  const _VariantMenuPill({required this.value, required this.onChanged});

  // Non-null sentinel so PopupMenuButton invokes onSelected instead of
  // treating the selection as a barrier dismissal.
  static const _anyVariant = '_any_variant';

  final DynamicSchemeVariant? value;
  final ValueChanged<DynamicSchemeVariant?> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    final label = value == null ? 'Any variant' : formatVariantName(value!);

    return PopupMenuButton<Object>(
      tooltip: 'Filter DynamicSchemeVariant',
      color: palette.surface,
      onSelected: (selected) {
        if (identical(selected, _anyVariant)) {
          onChanged(null);
        } else if (selected is DynamicSchemeVariant) {
          onChanged(selected);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<Object>(
          value: _anyVariant,
          child: Row(
            children: [
              const Expanded(child: Text('Any variant (random)')),
              if (value == null) const Icon(Icons.check_rounded, size: 16),
            ],
          ),
        ),
        const PopupMenuDivider(),
        for (final variant in DynamicSchemeVariant.values)
          PopupMenuItem<Object>(
            value: variant,
            child: Row(
              children: [
                Expanded(child: Text(formatVariantName(variant))),
                if (variant == value) const Icon(Icons.check_rounded, size: 16),
              ],
            ),
          ),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: palette.track,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 17,
              color: palette.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sleek segmented pill control styled after Chroma Folio.
class StudioPillSelector<T> extends StatelessWidget {
  const StudioPillSelector({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<({T value, String label})> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.track,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: [
          for (final option in options)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (option.value != value) {
                    HapticFeedback.selectionClick();
                    onChanged(option.value);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: kStudioEaseOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: option.value == value
                        ? palette.activePill
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: option.value == value && !isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    option.label,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: option.value == value
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: option.value == value
                          ? palette.ink
                          : palette.inkMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Quiet circular icon button matching Chroma Folio's top-bar buttons.
class StudioIconButton extends StatefulWidget {
  const StudioIconButton({
    super.key,
    this.icon,
    this.iconBuilder,
    required this.tooltip,
    required this.onTap,
    this.ink,
  }) : assert(icon != null || iconBuilder != null);

  final IconData? icon;
  final Widget Function(Color color)? iconBuilder;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? ink;

  @override
  State<StudioIconButton> createState() => _StudioIconButtonState();
}

class _StudioIconButtonState extends State<StudioIconButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    final ink = widget.ink ?? palette.ink;
    final enabled = widget.onTap != null;
    final iconColor = ink.withValues(alpha: enabled ? 0.84 : 0.25);
    final fill = !enabled
        ? 0.0
        : _pressed
        ? 0.16
        : _hovered
        ? 0.11
        : 0.06;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.tooltip,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _pressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: kStudioEaseOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: fill),
                  shape: BoxShape.circle,
                ),
                child:
                    widget.iconBuilder?.call(iconColor) ??
                    Icon(widget.icon, size: 18, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GitHubMark extends StatelessWidget {
  const _GitHubMark({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GitHubMarkPainter(color),
    );
  }
}

class _GitHubMarkPainter extends CustomPainter {
  const _GitHubMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final path = Path()
      ..moveTo(12.00 * s, 0.50 * s)
      ..cubicTo(5.37 * s, 0.50 * s, 0.00 * s, 5.87 * s, 0.00 * s, 12.50 * s)
      ..cubicTo(0.00 * s, 17.80 * s, 3.44 * s, 22.30 * s, 8.21 * s, 23.89 * s)
      ..cubicTo(8.81 * s, 24.00 * s, 9.03 * s, 23.63 * s, 9.03 * s, 23.31 * s)
      ..cubicTo(9.03 * s, 23.02 * s, 9.02 * s, 22.27 * s, 9.01 * s, 21.26 * s)
      ..cubicTo(5.67 * s, 21.99 * s, 4.97 * s, 19.65 * s, 4.97 * s, 19.65 * s)
      ..cubicTo(4.42 * s, 18.26 * s, 3.64 * s, 17.89 * s, 3.64 * s, 17.89 * s)
      ..cubicTo(2.55 * s, 17.15 * s, 3.72 * s, 17.16 * s, 3.72 * s, 17.16 * s)
      ..cubicTo(4.92 * s, 17.24 * s, 5.56 * s, 18.40 * s, 5.56 * s, 18.40 * s)
      ..cubicTo(6.63 * s, 20.23 * s, 8.37 * s, 19.70 * s, 9.05 * s, 19.40 * s)
      ..cubicTo(9.16 * s, 18.62 * s, 9.47 * s, 18.10 * s, 9.81 * s, 17.80 * s)
      ..cubicTo(7.14 * s, 17.50 * s, 4.34 * s, 16.47 * s, 4.34 * s, 11.87 * s)
      ..cubicTo(4.34 * s, 10.56 * s, 4.81 * s, 9.49 * s, 5.58 * s, 8.65 * s)
      ..cubicTo(5.46 * s, 8.35 * s, 5.04 * s, 7.13 * s, 5.70 * s, 5.47 * s)
      ..cubicTo(5.70 * s, 5.47 * s, 6.71 * s, 5.15 * s, 9.00 * s, 6.70 * s)
      ..cubicTo(9.96 * s, 6.43 * s, 10.98 * s, 6.30 * s, 12.00 * s, 6.30 * s)
      ..cubicTo(13.02 * s, 6.30 * s, 14.04 * s, 6.43 * s, 15.00 * s, 6.70 * s)
      ..cubicTo(17.29 * s, 5.15 * s, 18.30 * s, 5.47 * s, 18.30 * s, 5.47 * s)
      ..cubicTo(18.96 * s, 7.13 * s, 18.54 * s, 8.35 * s, 18.42 * s, 8.65 * s)
      ..cubicTo(19.19 * s, 9.49 * s, 19.66 * s, 10.56 * s, 19.66 * s, 11.87 * s)
      ..cubicTo(
        19.66 * s,
        16.48 * s,
        16.85 * s,
        17.50 * s,
        14.18 * s,
        17.79 * s,
      )
      ..cubicTo(
        14.61 * s,
        18.16 * s,
        14.99 * s,
        18.89 * s,
        14.99 * s,
        20.01 * s,
      )
      ..cubicTo(
        14.99 * s,
        21.61 * s,
        14.98 * s,
        22.91 * s,
        14.98 * s,
        23.30 * s,
      )
      ..cubicTo(
        14.98 * s,
        23.62 * s,
        15.20 * s,
        24.00 * s,
        15.81 * s,
        23.88 * s,
      )
      ..cubicTo(
        20.57 * s,
        22.30 * s,
        24.00 * s,
        17.80 * s,
        24.00 * s,
        12.50 * s,
      )
      ..cubicTo(24.00 * s, 5.87 * s, 18.63 * s, 0.50 * s, 12.00 * s, 0.50 * s)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_GitHubMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
