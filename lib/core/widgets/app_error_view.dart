import 'package:flutter/material.dart';

import 'package:repara/core/widgets/app_empty_view.dart';
import 'package:repara/core/widgets/primary_button.dart';

/// Error state with an icon, title, friendly message and optional retry.
///
/// Only the friendly [message] is rendered; exception objects, stack traces
/// and internal details must be translated before reaching this widget.
/// While [isRetrying] is true the retry button is disabled and shows a
/// progress indicator.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.title = 'Não foi possível carregar',
    this.onRetry,
    this.retryLabel = 'Tentar novamente',
    this.isRetrying = false,
  });

  /// Friendly pt-BR message safe to show to the user.
  final String message;

  /// Error title.
  final String title;

  /// Optional retry action; without it no button is rendered.
  final VoidCallback? onRetry;

  /// Retry button label.
  final String retryLabel;

  /// Disables the retry button while a retry is in flight.
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;

    return AppEmptyView(
      title: title,
      message: message,
      icon: Icons.error_outline,
      iconColor: Theme.of(context).colorScheme.error,
      action: retry == null
          ? null
          : PrimaryButton(
              label: retryLabel,
              onPressed: retry,
              isLoading: isRetrying,
            ),
    );
  }
}
