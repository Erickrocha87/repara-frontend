// Phase 1 widget tests for StatusChip: enum -> label/color mapping, custom
// presentation label, semantics, contrast and large text scale.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/core/widgets/status_chip.dart';
import 'package:repara/features/demands/domain/entities/status_demanda.dart';

const _expectedLabels = <StatusDemanda, String>{
  StatusDemanda.aberta: 'Aberta',
  StatusDemanda.emAndamento: 'Encaminhada',
  StatusDemanda.resolvida: 'Resolvida',
  StatusDemanda.rejeitada: 'Rejeitada',
};

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

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = math.max(foregroundLuminance, backgroundLuminance);
  final darker = math.min(foregroundLuminance, backgroundLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  testWidgets('maps all four statuses to their default labels', (
    WidgetTester tester,
  ) async {
    for (final entry in _expectedLabels.entries) {
      await _pump(tester, StatusChip(status: entry.key));

      expect(
        find.text(entry.value),
        findsOneWidget,
        reason: 'status ${entry.key}',
      );
    }
  });

  testWidgets('accepts a presentation label override', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const StatusChip(status: StatusDemanda.emAndamento, label: 'Em análise'),
    );

    expect(find.text('Em análise'), findsOneWidget);
    expect(find.text('Encaminhada'), findsNothing);
  });

  testWidgets('exposes the status through semantics', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    for (final entry in _expectedLabels.entries) {
      await _pump(tester, StatusChip(status: entry.key));

      expect(
        find.bySemanticsLabel('Status: ${entry.value}'),
        findsOneWidget,
        reason: 'status ${entry.key}',
      );
    }

    handle.dispose();
  });

  testWidgets('rendered foreground/background contrast is at least 4.5:1', (
    WidgetTester tester,
  ) async {
    for (final entry in _expectedLabels.entries) {
      await _pump(tester, StatusChip(status: entry.key));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusChip),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration;
      expect(decoration, isA<BoxDecoration>());
      final background = (decoration! as BoxDecoration).color;
      expect(background, isNotNull);

      final text = tester.widget<Text>(find.text(entry.value));
      final foreground = text.style?.color;
      expect(foreground, isNotNull);

      expect(
        _contrastRatio(foreground!, background!),
        greaterThanOrEqualTo(4.5),
        reason: 'status ${entry.key}',
      );
    }
  });

  testWidgets('keeps the 24 px minimum height', (WidgetTester tester) async {
    await _pump(tester, const StatusChip(status: StatusDemanda.aberta));

    expect(
      tester.getSize(find.byType(StatusChip)).height,
      greaterThanOrEqualTo(ReparaSizes.statusChipHeight),
    );
  });

  testWidgets('does not overflow at 2.0 text scale on a 360x640 screen', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      const StatusChip(status: StatusDemanda.emAndamento),
      textScale: 2.0,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Encaminhada'), findsOneWidget);
  });
}
