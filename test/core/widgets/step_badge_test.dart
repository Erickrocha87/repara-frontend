// Phase 1 widget tests for StepBadge: text, semantics, sizing, colors and
// large text scale.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/core/widgets/step_badge.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double textScale = 1.0,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
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

void main() {
  testWidgets('renders "<current> de <total>"', (WidgetTester tester) async {
    await _pump(tester, const StepBadge(current: 1, total: 3));

    expect(find.text('1 de 3'), findsOneWidget);
  });

  testWidgets('exposes the step through semantics', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await _pump(tester, const StepBadge(current: 1, total: 3));

    expect(find.bySemanticsLabel('Etapa 1 de 3'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('keeps the 64 x 28 minimum size', (WidgetTester tester) async {
    await _pump(tester, const StepBadge(current: 1, total: 3));

    final size = tester.getSize(find.byType(StepBadge));
    expect(size.width, greaterThanOrEqualTo(ReparaSizes.stepBadgeMinWidth));
    expect(size.height, greaterThanOrEqualTo(ReparaSizes.stepBadgeHeight));
  });

  testWidgets('uses the capture surface-alt colors and selector radius', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const StepBadge(current: 1, total: 3));

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(StepBadge),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration;
    expect(decoration, isA<BoxDecoration>());
    final boxDecoration = decoration as BoxDecoration;
    expect(boxDecoration.color, ReparaColors.captureSurfaceAlt);
    expect(
      boxDecoration.borderRadius,
      BorderRadius.circular(ReparaRadii.selector),
    );

    final text = tester.widget<Text>(find.text('1 de 3'));
    expect(text.style?.color, ReparaColors.captureText);
  });

  testWidgets('does not overflow at 2.0 text scale on a 360x640 screen', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, const StepBadge(current: 1, total: 3), textScale: 2.0);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('1 de 3'), findsOneWidget);
  });

  test('rejects out-of-range steps', () {
    expect(() => StepBadge(current: 0, total: 3), throwsAssertionError);
    expect(() => StepBadge(current: 4, total: 3), throwsAssertionError);
  });
}
