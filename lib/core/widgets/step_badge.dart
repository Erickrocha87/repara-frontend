import 'package:flutter/material.dart';

import 'package:repara/app/theme/tokens.dart';
import 'package:repara/app/theme/typography.dart';

/// "current de total" pill used by the report flow top bar (e.g. "1 de 3").
class StepBadge extends StatelessWidget {
  const StepBadge({super.key, required this.current, required this.total})
    : assert(current >= 1, 'current must be >= 1'),
      assert(current <= total, 'current must be <= total');

  /// Current step, 1-based.
  final int current;

  /// Total number of steps.
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Etapa $current de $total',
      container: true,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: ReparaSizes.stepBadgeMinWidth,
          minHeight: ReparaSizes.stepBadgeHeight,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ReparaColors.captureSurfaceAlt,
            borderRadius: BorderRadius.circular(ReparaRadii.selector),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ReparaSpacing.xs),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                '$current de $total',
                style: ReparaTypography.label.copyWith(
                  color: ReparaColors.captureText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
