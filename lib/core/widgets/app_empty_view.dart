import 'package:flutter/material.dart';

import 'package:repara/app/theme/tokens.dart';

/// Centered empty-state view with an icon, title, message and optional action.
///
/// The content stays centered when it fits and becomes scrollable when it does
/// not (the same pattern as `ConfigurationErrorApp`), so it survives small
/// screens and large text scales without clipping. It also works when the
/// parent provides unbounded height.
///
/// Colors come from the active [ColorScheme] (`onSurfaceVariant` for the icon
/// and message), so the same widget works on light surfaces and on the dark
/// capture theme.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.action,
  });

  /// Short title, rendered with the h3 style and header semantics.
  final String title;

  /// Explanatory body text.
  final String message;

  /// Decorative icon.
  final IconData icon;

  /// Icon color; defaults to [ColorScheme.onSurfaceVariant].
  final Color? iconColor;

  /// Optional action widget (for example, a retry or register button).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final actionWidget = action;
    final scheme = Theme.of(context).colorScheme;
    final mutedColor = scheme.onSurfaceVariant;
    final resolvedIconColor = iconColor ?? mutedColor;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(ReparaSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: resolvedIconColor,
                  size: ReparaSizes.iconTile,
                ),
                const SizedBox(height: ReparaSpacing.md),
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: ReparaSpacing.xs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: mutedColor),
                ),
                if (actionWidget != null) ...[
                  const SizedBox(height: ReparaSpacing.lg),
                  actionWidget,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
