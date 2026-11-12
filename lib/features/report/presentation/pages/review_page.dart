import 'package:flutter/material.dart';

/// Explicit Phase 0 stub for the new report flow, step 3 of 3 (review).
///
/// This is NOT finished UI: the review and submission screen (summary card,
/// submit with loading/error states) is Phase 5 work. The page exists only so
/// the `/report/review` route resolves and the flow can be navigated and
/// smoke-tested.
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova ocorrência')),
      body: const Center(
        child: Text(
          'Etapa 3 de 3 — Revisão (stub da Fase 0; implementação na Fase 5)',
        ),
      ),
    );
  }
}
