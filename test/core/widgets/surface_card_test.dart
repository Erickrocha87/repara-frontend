// Phase 1 widget tests for SurfaceCard: content, tap affordance, semantics
// and design tokens.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/core/widgets/surface_card.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double textScale = 1.0,
  ThemeData? theme,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    ),
  );
}

BoxDecoration? _cardDecoration(WidgetTester tester) {
  final decoratedBox = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(SurfaceCard),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  final decoration = decoratedBox.decoration;
  return decoration is BoxDecoration ? decoration : null;
}

BoxDecoration? _focusRingDecoration(WidgetTester tester, Color color) {
  final boxes = tester.widgetList<DecoratedBox>(
    find.descendant(
      of: find.byType(SurfaceCard),
      matching: find.byType(DecoratedBox),
    ),
  );
  for (final box in boxes) {
    final decoration = box.decoration;
    if (decoration is! BoxDecoration) {
      continue;
    }
    final border = decoration.border;
    if (border is Border && border.top.color == color) {
      return decoration;
    }
  }
  return null;
}

void main() {
  testWidgets('renders its child', (WidgetTester tester) async {
    await _pump(tester, const SurfaceCard(child: Text('Conteúdo do card')));

    expect(find.text('Conteúdo do card'), findsOneWidget);
  });

  testWidgets('tap fires when onTap is provided', (WidgetTester tester) async {
    var taps = 0;
    await _pump(
      tester,
      SurfaceCard(onTap: () => taps += 1, child: const Text('Toque')),
    );

    await tester.tap(find.text('Toque'));

    expect(taps, 1);
  });

  testWidgets('has no tap semantics when onTap is null', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await _pump(tester, const SurfaceCard(child: Text('Sem ação')));

    final semantics = tester.getSemantics(find.text('Sem ação'));
    expect(
      semantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isFalse,
    );

    handle.dispose();
  });

  testWidgets('has tap semantics when onTap is provided', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await _pump(
      tester,
      SurfaceCard(onTap: () {}, child: const Text('Acionável')),
    );

    final semantics = tester.getSemantics(find.text('Acionável'));
    expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    handle.dispose();
  });

  testWidgets('uses the scheme surface, outline and radius tokens', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const SurfaceCard(child: Text('Card')));

    final boxDecoration = _cardDecoration(tester);
    expect(boxDecoration, isNotNull);
    expect(boxDecoration?.color, AppTheme.light.colorScheme.surface);
    expect(boxDecoration?.borderRadius, BorderRadius.circular(ReparaRadii.lg));

    final border = boxDecoration?.border;
    expect(border, isA<Border>());
    final side = (border as Border).top;
    expect(side.color, AppTheme.light.colorScheme.outline);
    expect(side.width, ReparaSizes.hairline);
  });

  testWidgets('uses the capture scheme surface and outline', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const SurfaceCard(child: Text('Card escuro')),
      theme: AppTheme.capture,
    );

    final boxDecoration = _cardDecoration(tester);
    expect(boxDecoration?.color, AppTheme.capture.colorScheme.surface);
    final border = boxDecoration?.border;
    expect(border, isA<Border>());
    expect((border as Border).top.color, AppTheme.capture.colorScheme.outline);
  });

  testWidgets('autofocus paints a solid 2 px ring in the scheme primary', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      SurfaceCard(
        autofocus: true,
        onTap: () {},
        child: const Text('Card com foco'),
      ),
    );
    await tester.pump();

    final ring = _focusRingDecoration(
      tester,
      AppTheme.light.colorScheme.primary,
    );
    expect(ring, isNotNull);
    expect(
      ring?.border,
      Border.all(
        color: AppTheme.light.colorScheme.primary,
        width: ReparaSizes.focusRingWidth,
      ),
    );
    expect(
      find.descendant(
        of: find.byType(SurfaceCard),
        matching: find.byType(IgnorePointer),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tappable cards enforce the 48 px minimum touch target', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      SurfaceCard(onTap: () {}, child: const SizedBox(width: 8, height: 8)),
    );

    expect(
      tester.getSize(find.byType(SurfaceCard)).height,
      greaterThanOrEqualTo(ReparaSizes.minTouchTarget),
    );
  });

  testWidgets('static cards do not force the touch target height', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const SurfaceCard(child: SizedBox(width: 8, height: 8)),
    );

    expect(
      tester.getSize(find.byType(SurfaceCard)).height,
      lessThan(ReparaSizes.minTouchTarget),
    );
  });

  testWidgets('grows without overflow at 2.0 text scale on a 360x640 screen', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      const SurfaceCard(
        child: Text(
          'Um título de card bem longo que quebra em várias linhas para '
          'validar o crescimento vertical sem overflow.',
        ),
      ),
      textScale: 2.0,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
