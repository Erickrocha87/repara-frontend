import 'package:flutter/material.dart';

/// Explicit Phase 0 stub for the new report flow, step 2 of 3 (details).
///
/// This is NOT finished UI: the details form (photo with redo, category
/// selector, description, location summary) is Phase 5 work. The page exists
/// only so the `/report/details` route resolves and the flow can be navigated
/// and smoke-tested.
class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova ocorrência')),
      body: const Center(
        child: Text(
          'Etapa 2 de 3 — Detalhes (stub da Fase 0; implementação na Fase 5)',
        ),
      ),
    );
  }
}
