// Phase 1 tests for the debug design-system gallery and its release guard.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/router/app_router.dart';
import 'package:repara/app/router/route_error_page.dart';
import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/core/widgets/app_empty_view.dart';
import 'package:repara/core/widgets/app_error_view.dart';
import 'package:repara/core/widgets/app_skeleton.dart';
import 'package:repara/core/widgets/location_pill.dart';
import 'package:repara/core/widgets/primary_button.dart';
import 'package:repara/core/widgets/status_chip.dart';
import 'package:repara/core/widgets/step_badge.dart';
import 'package:repara/core/widgets/surface_card.dart';
import 'package:repara/dev/design_system_gallery.dart';

import '../helpers/pump_app.dart';

Future<void> _pumpGallery(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: const DesignSystemGalleryPage()),
  );
  await tester.pump();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pump();
}

void main() {
  testWidgets('renders the token sections and every base component', (
    WidgetTester tester,
  ) async {
    await _pumpGallery(tester);

    expect(find.text('Design system'), findsOneWidget);
    expect(find.text('Cores'), findsOneWidget);

    await _scrollTo(tester, find.text('Tipografia'));
    expect(find.text('Tipografia'), findsOneWidget);

    await _scrollTo(tester, find.text('Espaçamento e raios'));
    expect(find.text('Espaçamento e raios'), findsOneWidget);

    await _scrollTo(tester, find.text('Componentes'));
    expect(find.text('Componentes'), findsOneWidget);

    await _scrollTo(tester, find.text('PrimaryButton'));
    expect(find.byType(PrimaryButton), findsWidgets);
    expect(
      find.descendant(
        of: find.widgetWithText(PrimaryButton, 'Carregando'),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    await _scrollTo(tester, find.text('StatusChip'));
    expect(find.byType(StatusChip), findsNWidgets(5));
    expect(find.text('Em análise'), findsOneWidget);

    await _scrollTo(tester, find.text('StepBadge'));
    expect(find.byType(StepBadge), findsOneWidget);
    expect(find.text('1 de 3'), findsOneWidget);

    await _scrollTo(tester, find.text('SurfaceCard'));
    expect(find.byType(SurfaceCard), findsNWidgets(2));

    await _scrollTo(tester, find.text('AppSkeleton'));
    expect(find.byType(AppSkeleton), findsWidgets);

    await _scrollTo(tester, find.text('AppEmptyView'));
    expect(
      find.widgetWithText(AppEmptyView, 'Nenhuma demanda por perto'),
      findsOneWidget,
    );

    await _scrollTo(tester, find.text('Nova tentativa em andamento.'));
    expect(find.byType(AppErrorView), findsNWidgets(2));

    await _scrollTo(tester, find.text('LocationPill'));
    expect(find.byType(LocationPill), findsNWidgets(2));
  });

  testWidgets('renders sizes, shadows, durations and the capture theme', (
    WidgetTester tester,
  ) async {
    await _pumpGallery(tester);

    expect(find.text('Foco'), findsOneWidget);
    expect(find.text('Botão com foco visível'), findsOneWidget);

    await _scrollTo(tester, find.text('Tamanhos'));
    expect(find.text('primaryButtonMinWidth'), findsOneWidget);
    expect(find.text('focusRingWidth'), findsOneWidget);

    await _scrollTo(tester, find.text('Sombras'));
    expect(find.text('cta'), findsOneWidget);
    expect(find.text('sheet'), findsOneWidget);

    await _scrollTo(tester, find.text('Durações'));
    expect(find.text('fast'), findsOneWidget);
    expect(find.text('standard'), findsOneWidget);

    await _scrollTo(tester, find.text('Tema de captura'));
    expect(find.text('Tema de captura'), findsOneWidget);

    final capturePreview = find.byWidgetPredicate(
      (widget) => widget is Theme && widget.data == AppTheme.capture,
    );
    expect(capturePreview, findsOneWidget);
    expect(
      find.descendant(
        of: capturePreview,
        matching: find.widgetWithText(StepBadge, '2 de 3'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: capturePreview,
        matching: find.widgetWithText(
          LocationPill,
          'Local capturado · precisão ±8 m',
        ),
      ),
      findsOneWidget,
    );

    await _scrollTo(tester, find.text('Componentes'));
    expect(find.text('Componentes'), findsOneWidget);
  });

  testWidgets('demo callbacks show a SnackBar', (WidgetTester tester) async {
    await _pumpGallery(tester);
    await _scrollTo(tester, find.text('PrimaryButton'));

    await tester.tap(find.widgetWithText(PrimaryButton, 'Ação principal'));
    await tester.pump();

    expect(find.text('Ação principal acionada'), findsOneWidget);

    // Let the SnackBar timer expire so the test leaves no pending timer.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the gallery route resolves when enabled', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      overrides: [
        appRouterProvider.overrideWith(
          (ref) => buildAppRouter(
            initialLocation: AppRoutes.designSystem,
            includeDesignSystemGallery: true,
          ),
        ),
      ],
    );
    await tester.pump();

    expect(find.byType(DesignSystemGalleryPage), findsOneWidget);
    expect(find.text('Design system'), findsOneWidget);
  });

  testWidgets('the gallery route is guarded when disabled', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      overrides: [
        appRouterProvider.overrideWith(
          (ref) => buildAppRouter(
            initialLocation: AppRoutes.designSystem,
            includeDesignSystemGallery: false,
          ),
        ),
      ],
    );
    await tester.pump();

    expect(find.byType(DesignSystemGalleryPage), findsNothing);
    expect(find.byType(RouteErrorPage), findsOneWidget);
    expect(find.text('Página não encontrada'), findsOneWidget);
  });
}
