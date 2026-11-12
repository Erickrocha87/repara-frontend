// Phase 1 widget tests for AppErrorView: friendly copy, retry behavior,
// retrying state and the absence of exception details.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/core/widgets/app_error_view.dart';
import 'package:repara/core/widgets/primary_button.dart';

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

double _linearizeChannel(double channel) {
  return channel <= 0.04045
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

double _relativeLuminance(Color color) {
  return 0.2126 * _linearizeChannel(color.r) +
      0.7152 * _linearizeChannel(color.g) +
      0.0722 * _linearizeChannel(color.b);
}

double _contrastRatio(Color a, Color b) {
  final luminanceA = _relativeLuminance(a);
  final luminanceB = _relativeLuminance(b);
  final lighter = math.max(luminanceA, luminanceB);
  final darker = math.min(luminanceA, luminanceB);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  testWidgets('renders title, message, icon and retry', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      AppErrorView(message: 'Falha ao carregar', onRetry: () {}),
    );

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(find.text('Falha ao carregar'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
    expect(icon.color, ReparaColors.error);
  });

  testWidgets('retry tap fires', (WidgetTester tester) async {
    var taps = 0;
    await _pump(
      tester,
      AppErrorView(message: 'Falha ao carregar', onRetry: () => taps += 1),
    );

    await tester.tap(find.text('Tentar novamente'));

    expect(taps, 1);
  });

  testWidgets('isRetrying disables the retry button', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      AppErrorView(
        message: 'Falha ao carregar',
        isRetrying: true,
        onRetry: () => taps += 1,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    expect(taps, 0);
  });

  testWidgets('never renders exception or stack details', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const AppErrorView(message: 'Não foi possível carregar as demandas.'),
    );

    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('StackTrace'), findsNothing);
    expect(find.textContaining('#0'), findsNothing);
    expect(find.byType(PrimaryButton), findsNothing);
  });

  testWidgets('uses the capture scheme error and muted colors with contrast', (
    WidgetTester tester,
  ) async {
    const messageText = 'Não foi possível carregar as demandas.';
    await _pump(
      tester,
      const AppErrorView(message: messageText),
      theme: AppTheme.capture,
    );

    final scheme = AppTheme.capture.colorScheme;
    final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
    expect(icon.color, scheme.error);

    final message = tester.widget<Text>(find.text(messageText));
    expect(message.style?.color, scheme.onSurfaceVariant);

    final background = AppTheme.capture.scaffoldBackgroundColor;
    expect(
      _contrastRatio(message.style?.color ?? Colors.transparent, background),
      greaterThanOrEqualTo(4.5),
      reason: 'error message text contrast',
    );
    expect(
      _contrastRatio(icon.color ?? Colors.transparent, background),
      greaterThanOrEqualTo(3.0),
      reason: 'error icon contrast',
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
      AppErrorView(
        message:
            'Não foi possível carregar as demandas próximas. Verifique a '
            'conexão e tente novamente em alguns instantes.',
        onRetry: () {},
      ),
      textScale: 2.0,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
