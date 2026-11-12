import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/app.dart';
import 'package:repara/app/bootstrap.dart';
import 'package:repara/app/configuration_error_app.dart';
import 'package:repara/core/config/app_config.dart';

void main() {
  testWidgets('mock mode boots the real app', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildRootAppFor(
        const AppConfig(mockMode: true, mockScenario: MockScenario.success),
      ),
    );

    expect(find.byType(ReparaApp), findsOneWidget);
    expect(find.byType(ConfigurationErrorApp), findsNothing);
  });

  testWidgets('release without mock mode shows the configuration error app', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildRootAppFor(
        const AppConfig(mockMode: false, mockScenario: MockScenario.success),
      ),
    );

    expect(find.byType(ConfigurationErrorApp), findsOneWidget);
    expect(find.byType(ReparaApp), findsNothing);
    expect(find.text('Configuração inválida'), findsOneWidget);
    expect(find.textContaining('MOCK_MODE=true'), findsOneWidget);
    expect(find.textContaining('não existe'), findsOneWidget);
  });

  // L-3: the bootstrap try/catch glue is exercised through the pure factory
  // `buildRootAppFromConfig`, without `runApp`.
  testWidgets(
    'buildRootAppFromConfig renders the thrown configuration message',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildRootAppFromConfig(
          () => throw const AppConfigError('config quebrada para teste'),
        ),
      );

      expect(find.byType(ConfigurationErrorApp), findsOneWidget);
      expect(find.text('config quebrada para teste'), findsOneWidget);
    },
  );

  testWidgets('buildRootAppFromConfig boots the real app in mock mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildRootAppFromConfig(
        () =>
            const AppConfig(mockMode: true, mockScenario: MockScenario.success),
      ),
    );

    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(ReparaApp), findsOneWidget);
    expect(find.byType(ConfigurationErrorApp), findsNothing);
  });

  testWidgets(
    'buildRootAppFromConfig shows the configuration error without mock mode',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildRootAppFromConfig(
          () => const AppConfig(
            mockMode: false,
            mockScenario: MockScenario.success,
          ),
        ),
      );

      expect(find.byType(ConfigurationErrorApp), findsOneWidget);
      expect(find.byType(ReparaApp), findsNothing);
      expect(find.text(AppConfig.releaseMockDisabledMessage), findsOneWidget);
    },
  );

  // Regression test for the independent UI review (2026-11-11), finding M-1:
  // the configuration error message (~300 chars) must stay centered when it
  // fits and scroll when it does not, instead of overflowing vertically on
  // 360x640-class screens at large text scales.
  testWidgets(
    'configuration error screen does not overflow at 2.0 text scale on a small screen',
    (WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(360, 640)
        ..devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: ConfigurationErrorApp(
            message: AppConfig.releaseMockDisabledMessage,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('MOCK_MODE=true'), findsOneWidget);
    },
  );

  testWidgets('configuration error title is a header inside a safe area', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const ConfigurationErrorApp(message: 'configuração de teste'),
    );

    final semantics = tester.getSemantics(find.text('Configuração inválida'));
    expect(semantics.getSemanticsData().flagsCollection.isHeader, isTrue);
    expect(find.byType(SafeArea), findsWidgets);

    handle.dispose();
  });
}
