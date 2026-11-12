import 'package:flutter/material.dart';

import 'package:repara/app/theme/tokens.dart';

/// Static loading placeholder used while content is being fetched.
///
/// Deliberately not animated: a static block keeps widget tests deterministic
/// and avoids a perpetual ticker. [width] null fills the available width, so
/// the parent must provide a bounded width in that case.
///
/// The block keeps the [ReparaColors.skeletonBase] fill but adds a hairline
/// [ColorScheme.outline] border so it stays perceptible on light surfaces.
///
/// The block is decorative and excluded from semantics by default. Pass
/// [semanticLabel] when the placeholder itself should be announced (for
/// example, "Carregando demandas próximas"); the label is a live region so
/// screen readers announce the loading state when it appears.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.semanticLabel,
  });

  /// Placeholder width; null fills the available width.
  final double? width;

  /// Placeholder height.
  final double height;

  /// Corner radius; defaults to [ReparaRadii.sm].
  final BorderRadius? borderRadius;

  /// Optional accessibility label for the placeholder.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final skeleton = SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ReparaColors.skeletonBase,
          borderRadius: borderRadius ?? BorderRadius.circular(ReparaRadii.sm),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: ReparaSizes.hairline,
          ),
        ),
      ),
    );

    final label = semanticLabel;
    if (label == null) {
      return ExcludeSemantics(child: skeleton);
    }
    return Semantics(
      label: label,
      container: true,
      liveRegion: true,
      excludeSemantics: true,
      child: skeleton,
    );
  }
}
