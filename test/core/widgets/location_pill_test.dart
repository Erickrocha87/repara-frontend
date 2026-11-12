// Phase 1 widget tests for LocationPill: label, trailing action, absent dead
// button, minimum height and large text scale.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/core/widgets/location_pill.dart';

void _noop() {}

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
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the label and the trailing action', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const LocationPill(
        label: 'Porto Alegre · Centro Histórico',
        onTrailingTap: _noop,
      ),
    );

    expect(find.text('Porto Alegre · Centro Histórico'), findsOneWidget);
    expect(find.text('Trocar'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.explore_outlined));
    expect(icon.color, ReparaColors.brandPrimary);
  });

  testWidgets('trailing tap fires', (WidgetTester tester) async {
    var taps = 0;
    await _pump(
      tester,
      LocationPill(label: 'Centro Histórico', onTrailingTap: () => taps += 1),
    );

    await tester.tap(find.text('Trocar'));

    expect(taps, 1);
  });

  testWidgets('has no trailing button when onTrailingTap is null', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const LocationPill(label: 'Centro Histórico'));

    expect(find.text('Trocar'), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('keeps the 48 px minimum height', (WidgetTester tester) async {
    await _pump(tester, const LocationPill(label: 'Centro Histórico'));

    expect(
      tester.getSize(find.byType(LocationPill)).height,
      greaterThanOrEqualTo(ReparaSizes.locationPillHeight),
    );
  });

  testWidgets('uses the capture scheme surface, outline and primary icon', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const LocationPill(label: 'Local capturado · precisão ±8 m'),
      theme: AppTheme.capture,
    );

    final scheme = AppTheme.capture.colorScheme;
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(LocationPill),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration;
    expect(decoration, isA<BoxDecoration>());

    final boxDecoration = decoration as BoxDecoration;
    expect(boxDecoration.color, scheme.surface);
    final border = boxDecoration.border;
    expect(border, isA<Border>());
    expect((border as Border).top.color, scheme.outline);

    final icon = tester.widget<Icon>(find.byIcon(Icons.explore_outlined));
    expect(icon.color, scheme.primary);
  });

  testWidgets('grows without overflow at 2.0 text scale on a 360-wide screen', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      const SingleChildScrollView(
        padding: EdgeInsets.all(ReparaSpacing.md),
        child: LocationPill(
          label: 'Porto Alegre · Centro Histórico',
          onTrailingTap: _noop,
        ),
      ),
      textScale: 2.0,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(LocationPill)).width,
      lessThanOrEqualTo(360),
    );
    expect(
      tester.getSize(find.byType(LocationPill)).height,
      greaterThan(ReparaSizes.locationPillHeight),
    );
  });
}
