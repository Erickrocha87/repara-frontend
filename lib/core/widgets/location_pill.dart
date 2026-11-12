import 'package:flutter/material.dart';

import 'package:repara/app/theme/tokens.dart';

/// Outlined pill showing the current region/location with an optional trailing
/// text action (for example, "Trocar").
///
/// The trailing [TextButton] is rendered only when [onTrailingTap] is
/// provided, so there is never a dead button. The label uses an [Expanded]
/// slot and the pill grows vertically at large text scales instead of
/// overflowing horizontally.
class LocationPill extends StatelessWidget {
  const LocationPill({
    super.key,
    required this.label,
    this.onTrailingTap,
    this.trailingLabel = 'Trocar',
    this.icon = Icons.explore_outlined,
  });

  /// Location/region label.
  final String label;

  /// Optional trailing action; null hides the trailing button.
  final VoidCallback? onTrailingTap;

  /// Trailing button label.
  final String trailingLabel;

  /// Leading icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final trailingTap = onTrailingTap;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(
        minHeight: ReparaSizes.locationPillHeight,
      ),
      padding: const EdgeInsets.only(
        left: ReparaSpacing.md,
        right: ReparaSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(ReparaRadii.selector),
        border: Border.all(color: scheme.outline, width: ReparaSizes.hairline),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: ReparaSizes.iconSm),
          const SizedBox(width: ReparaSpacing.xs),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          if (trailingTap != null)
            TextButton(onPressed: trailingTap, child: Text(trailingLabel)),
        ],
      ),
    );
  }
}
