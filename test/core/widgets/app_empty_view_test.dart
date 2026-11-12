// Phase 1 widget tests for AppEmptyView: content, action, header semantics,
// styles, scrollability and large text scale.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/core/widgets/app_empty_view.dart';
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

void main() {
  testWidgets('renders title, message and action', (WidgetTester tester) async {
    await _pump(
      tester,
      AppEmptyView(
        title: 'Nenhuma demanda por perto',
        message: 'Tente outra região ou registre uma nova ocorrência.',
        action: PrimaryButton(label: 'Registrar', onPressed: () {}),
      ),
    );

    expect(find.text('Nenhuma demanda por perto'), findsOneWidget);
    expect(
      find.text('Tente outra região ou registre uma nova ocorrência.'),
      findsOneWidget,
    );
    expect(find.byType(PrimaryButton), findsOneWidget);
  });

  testWidgets('action tap fires', (WidgetTester tester) async {
    var taps = 0;
    await _pump(
      tester,
      AppEmptyView(
        title: 'Vazio',
        message: 'Mensagem',
        action: PrimaryButton(label: 'Registrar', onPressed: () => taps += 1),
      ),
    );

    await tester.tap(find.byType(PrimaryButton));

    expect(taps, 1);
  });

  testWidgets('uses h3 header semantics and the muted message color', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await _pump(
      tester,
      const AppEmptyView(title: 'Vazio', message: 'Mensagem'),
    );

    final semantics = tester.getSemantics(find.text('Vazio'));
    expect(semantics.getSemanticsData().flagsCollection.isHeader, isTrue);
    expect(semantics.getSemanticsData().flagsCollection.isLiveRegion, isTrue);

    final title = tester.widget<Text>(find.text('Vazio'));
    expect(title.style?.fontSize, 18);
    expect(title.style?.fontWeight, FontWeight.w600);

    final message = tester.widget<Text>(find.text('Mensagem'));
    expect(message.style?.color, ReparaColors.inkMuted);

    final icon = tester.widget<Icon>(find.byIcon(Icons.inbox_outlined));
    expect(icon.color, ReparaColors.inkMuted);

    expect(find.byType(SafeArea), findsOneWidget);

    handle.dispose();
  });

  testWidgets('uses the capture scheme colors under AppTheme.capture', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const AppEmptyView(title: 'Vazio', message: 'Mensagem'),
      theme: AppTheme.capture,
    );

    final scheme = AppTheme.capture.colorScheme;
    final message = tester.widget<Text>(find.text('Mensagem'));
    expect(message.style?.color, scheme.onSurfaceVariant);

    final icon = tester.widget<Icon>(find.byIcon(Icons.inbox_outlined));
    expect(icon.color, scheme.onSurfaceVariant);
  });

  testWidgets('uses a scroll view so large content does not overflow', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      AppEmptyView(
        title: 'Nenhuma demanda por perto',
        message:
            'Tente outra região ou registre uma nova ocorrência com uma '
            'descrição bem longa para forçar a rolagem em telas pequenas.',
        action: PrimaryButton(label: 'Registrar', onPressed: () {}),
      ),
      textScale: 2.0,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
