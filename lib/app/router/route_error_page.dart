import 'package:flutter/material.dart';

import 'package:repara/core/widgets/app_error_view.dart';

/// pt-BR fallback page shown by the app router for unknown locations.
///
/// Replaces go_router's default English error screen (L-5) and never exposes
/// the underlying exception, stack trace or route details. The router owns
/// navigation, so this page receives [onGoHome] instead of importing the
/// router itself (avoids an `app_router` <-> `route_error_page` cycle).
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key, required this.onGoHome});

  /// Navigates back to the map entry route.
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppErrorView(
          title: 'Página não encontrada',
          message: 'O endereço solicitado não existe ou foi movido.',
          retryLabel: 'Voltar ao mapa',
          onRetry: onGoHome,
        ),
      ),
    );
  }
}
