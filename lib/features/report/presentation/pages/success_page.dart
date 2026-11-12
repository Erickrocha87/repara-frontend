import 'package:flutter/material.dart';

/// Explicit Phase 0 stub for the success screen of the new report flow.
///
/// This is NOT finished UI: the real screen (check icon, mock tracking code,
/// "Voltar ao mapa" clearing the draft) is Phase 5 work, and it will require a
/// submission result via route guard. The page exists only so the
/// `/report/success` route resolves and the flow can be navigated and
/// smoke-tested.
class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ocorrência registrada')),
      body: const Center(
        child: Text('Sucesso (stub da Fase 0; implementação na Fase 5)'),
      ),
    );
  }
}
