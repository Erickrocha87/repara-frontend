// Phase 0 smoke tests: app boots at '/', the 'Registrar' CTA reaches the
// capture stub and can come back, and every report flow route resolves to
// its stub page.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/router/app_router.dart';
import 'package:repara/features/map/presentation/pages/map_page.dart';
import 'package:repara/features/report/presentation/pages/capture_page.dart';
import 'package:repara/features/report/presentation/pages/details_page.dart';
import 'package:repara/features/report/presentation/pages/review_page.dart';
import 'package:repara/features/report/presentation/pages/success_page.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('boots at the map route with the app title', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.pump();

    expect(find.text('Repara'), findsOneWidget);
    expect(find.byType(MapPage), findsOneWidget);
  });

  testWidgets(
    "'Registrar' opens the capture stub and back returns to the map",
    (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.byType(CapturePage), findsOneWidget);
      expect(
        find.text(
          'Etapa 1 de 3 — Captura (stub da Fase 0; implementação na Fase 4)',
        ),
        findsOneWidget,
      );

      // `tester.pageBack()` looks for the English tooltip 'Back'; the app is
      // single-locale pt-BR, where the AppBar back button tooltip is 'Voltar'.
      // Tap the localized back button the same way pageBack would.
      final localizations = MaterialLocalizations.of(
        tester.element(find.byType(CapturePage)),
      );
      await tester.tap(find.byTooltip(localizations.backButtonTooltip));
      await tester.pumpAndSettle();

      expect(find.byType(MapPage), findsOneWidget);
      expect(find.byType(CapturePage), findsNothing);
    },
  );

  testWidgets('report flow routes resolve to their stub pages', (
    WidgetTester tester,
  ) async {
    const routesByPage = <(String, Type)>[
      (AppRoutes.reportCapture, CapturePage),
      (AppRoutes.reportDetails, DetailsPage),
      (AppRoutes.reportReview, ReviewPage),
      (AppRoutes.reportSuccess, SuccessPage),
    ];
    for (final (route, pageType) in routesByPage) {
      // Unmount the previous tree first: Riverpod keeps an already-created
      // overridden provider alive when ProviderScope overrides are updated
      // in place, so a fresh ProviderScope per route is required for the
      // override's create function (fresh router) to actually run.
      await tester.pumpWidget(const SizedBox());
      await pumpApp(
        tester,
        overrides: [
          appRouterProvider.overrideWith(
            (ref) => buildAppRouter(initialLocation: route),
          ),
        ],
      );
      await tester.pump();

      expect(find.byType(pageType), findsOneWidget, reason: 'route $route');
    }
  });
}
