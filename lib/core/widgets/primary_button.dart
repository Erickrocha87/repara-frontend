import 'package:flutter/material.dart';

import 'package:repara/app/theme/tokens.dart';

/// Amber pill CTA used for primary actions.
///
/// The button inherits the app's [FilledButtonThemeData] (amber background,
/// ink foreground, stadium shape and a 56 px minimum height). It has no fixed
/// height, so large text scales grow the button instead of clipping the
/// label; the theme's minimum size keeps the touch target at least 56 px tall.
///
/// While [isLoading] is true the button is disabled ([onPressed] is ignored)
/// and a small progress indicator is shown next to [label]. Callers driving an
/// async action should set [isLoading] from their own state, so a second tap
/// after the next frame cannot fire the action again.
///
/// The enabled button gets the §5.3 CTA shadow; disabled and loading states
/// are flat so they do not look actionable.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = false,
    this.autofocus = false,
  });

  /// Button label.
  final String label;

  /// Action fired on tap; ignored while [isLoading] is true.
  final VoidCallback? onPressed;

  /// Disables the button and shows a progress indicator.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the button fills the available width.
  final bool expand;

  /// Requests focus when first mounted (used by tests and the gallery to show
  /// the focus ring deterministically).
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final leadingIcon = icon;

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      autofocus: autofocus,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelText = Text(label, textAlign: TextAlign.center);

          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                Semantics(
                  label: 'Carregando',
                  liveRegion: true,
                  child: const ExcludeSemantics(
                    child: SizedBox.square(
                      dimension: ReparaSpacing.md,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                const SizedBox(width: ReparaSpacing.xs),
              ] else if (leadingIcon != null) ...[
                Icon(leadingIcon, size: ReparaSizes.iconSm),
                const SizedBox(width: ReparaSpacing.xs),
              ],
              // Flexible needs a bounded width; inside an unbounded Row the
              // label must be a plain child or the Row asserts.
              if (constraints.hasBoundedWidth)
                Flexible(child: labelText)
              else
                labelText,
            ],
          );
        },
      ),
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      child: enabled
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ReparaRadii.pill),
                boxShadow: ReparaShadows.cta,
              ),
              child: button,
            )
          : button,
    );
  }
}
