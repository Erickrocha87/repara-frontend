import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:repara/app/router/app_routes.dart';
import 'package:repara/app/theme/tokens.dart';

/// Phase 0 placeholder for the map screen (prototype screen 01 — Mapa).
///
/// This is NOT the real screen: the actual map (header, region picker,
/// stylized map, pins, nearby demands sheet) is Phase 3 work. The page exists
/// so the `/` route resolves and the app is smoke-testable; the `Registrar`
/// CTA opens the Phase 0 capture stub so the report flow route is reachable.
/// Phase 3 replaces both the layout and this CTA.
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repara')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mapa — placeholder da Fase 0'),
            const Text('A tela real do mapa será implementada na Fase 3.'),
            const SizedBox(height: ReparaSpacing.lg),
            FilledButton(
              onPressed: () => context.go(AppRoutes.reportCapture),
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
