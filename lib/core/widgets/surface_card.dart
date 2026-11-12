import 'package:flutter/material.dart';

import 'package:repara/app/theme/tokens.dart';

/// Surface card with the design-system border and radius.
///
/// Colors come from the active [ColorScheme] (`surface` fill and `outline`
/// border), so the card also works on the dark capture theme.
///
/// When [onTap] is provided the whole card is tappable and gets the Material
/// ink ripple; when it is null the card has no tap affordance or tappable
/// area at all. Tappable cards enforce the 48 px minimum touch target.
///
/// Keyboard focus paints a solid 2 px ring in [ColorScheme.primary] on top of
/// the card. The ring is a positioned overlay, so gaining focus never shifts
/// the layout, and it ignores pointers so the card stays tappable.
class SurfaceCard extends StatefulWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(ReparaSpacing.md),
    this.autofocus = false,
  });

  /// Card content.
  final Widget child;

  /// Optional tap action; null makes the card static.
  final VoidCallback? onTap;

  /// Content padding.
  final EdgeInsetsGeometry padding;

  /// Requests focus when the card is first mounted. Exposed so tests and the
  /// design-system gallery can show the focus ring deterministically.
  final bool autofocus;

  @override
  State<SurfaceCard> createState() => _SurfaceCardState();
}

class _SurfaceCardState extends State<SurfaceCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(ReparaRadii.lg);

    Widget content = Padding(padding: widget.padding, child: widget.child);
    if (widget.onTap != null) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: ReparaSizes.minTouchTarget,
        ),
        child: content,
      );
    }

    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: borderRadius,
            border: Border.all(
              color: scheme.outline,
              width: ReparaSizes.hairline,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onFocusChange: (focused) => setState(() => _focused = focused),
              focusColor: Colors.transparent,
              autofocus: widget.autofocus,
              borderRadius: borderRadius,
              child: content,
            ),
          ),
        ),
        if (_focused)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: scheme.primary,
                    width: ReparaSizes.focusRingWidth,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
