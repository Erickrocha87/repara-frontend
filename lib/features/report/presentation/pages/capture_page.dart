import 'package:flutter/material.dart';

/// Explicit Phase 0 stub for the new report flow, step 1 of 3 (capture).
///
/// This is NOT finished UI: the real capture screen (dark theme, camera
/// preview, framing guides, location chip, shutter) is Phase 4 work. The page
/// exists only so the `/report/capture` route resolves and the flow can be
/// navigated and smoke-tested.
class CapturePage extends StatelessWidget {
  const CapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova ocorrência')),
      body: const Center(
        child: Text(
          'Etapa 1 de 3 — Captura (stub da Fase 0; implementação na Fase 4)',
        ),
      ),
    );
  }
}
