// Phase 1 tests for the pt-BR router error page (L-5) and for not swallowing
// programming errors that happen on matched locations.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/router/app_router.dart';
import 'package:repara/features/map/presentation/pages/map_page.dart';

import '../helpers/pump_app.dart';

Future<void> _pumpUnknownRoute(WidgetTester tester) async {
  await pumpApp(
    tester,
    overrides: [
      appRouterProvider.overrideWith(
        (ref) => buildAppRouter(initialLocation: '/rota-inexistente'),
      ),
    ],
  );
  await tester.pump();
}

void main() {
  testWidgets('unknown route renders the pt-BR error page', (
    WidgetTester tester,
  ) async {
    await _pumpUnknownRoute(tester);

    expect(find.text('Página não encontrada'), findsOneWidget);
    expect(
      find.text('O endereço solicitado não existe ou foi movido.'),
      findsOneWidget,
    );
    expect(find.text('Voltar ao mapa'), findsOneWidget);
    expect(find.text('Page Not Found'), findsNothing);
    expect(find.textContaining('GoException'), findsNothing);
  });

  testWidgets('"Voltar ao mapa" returns to the map page', (
    WidgetTester tester,
  ) async {
    await _pumpUnknownRoute(tester);

    await tester.tap(find.text('Voltar ao mapa'));
    await tester.pumpAndSettle();

    expect(find.byType(MapPage), findsOneWidget);
    expect(find.text('Página não encontrada'), findsNothing);
  });

  testWidgets('unknown locations are not reported as programming errors', (
    WidgetTester tester,
  ) async {
    final reported = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = reported.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    await _pumpUnknownRoute(tester);

    expect(reported, isEmpty);
  });

  test('matched route errors are reported without leaking to the UI', () {
    final reported = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = reported.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    final error = StateError('falha de programação');
    reportMatchedRouteError(error, '/report/capture');

    expect(reported, hasLength(1));
    expect(reported.single.exception, error);
    expect(reported.single.library, 'repara.router');
  });

  test('unmatched or missing errors are not reported', () {
    final reported = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = reported.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    final error = StateError('falha de programação');
    reportMatchedRouteError(error, '');
    reportMatchedRouteError(error, null);
    reportMatchedRouteError(null, '/report/capture');

    expect(reported, isEmpty);
  });
}
