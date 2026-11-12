// Phase 1 widget tests for PrimaryButton: enabled/disabled/loading states,
// double-tap protection, minimum height, expand and large text scale.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/core/widgets/primary_button.dart';

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
  testWidgets('enabled tap fires the callback', (WidgetTester tester) async {
    var taps = 0;
    await _pump(
      tester,
      PrimaryButton(label: 'Registrar', onPressed: () => taps += 1),
    );

    await tester.tap(find.byType(PrimaryButton));

    expect(taps, 1);
  });

  testWidgets('disabled tap does not fire', (WidgetTester tester) async {
    const taps = 0;
    await _pump(tester, const PrimaryButton(label: 'Registrar'));
    await tester.tap(find.byType(PrimaryButton));

    expect(taps, 0);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('loading disables the button and shows a progress indicator', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      PrimaryButton(
        label: 'Enviar',
        isLoading: true,
        onPressed: () => taps += 1,
      ),
    );

    expect(find.text('Enviar'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.tap(find.byType(PrimaryButton));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    expect(taps, 0);
  });

  testWidgets('a double tap while loading fires the action only once', (
    WidgetTester tester,
  ) async {
    final key = GlobalKey<_LoadingHarnessState>();
    await _pump(tester, _LoadingHarness(key: key));

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(key.currentState?.taps, 1);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    expect(key.currentState?.taps, 1);
  });

  testWidgets('keeps the 56 px minimum height', (WidgetTester tester) async {
    await _pump(tester, PrimaryButton(label: 'Registrar', onPressed: () {}));

    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(ReparaSizes.primaryButtonHeight),
    );
  });

  testWidgets('expand fills the available width', (WidgetTester tester) async {
    await _pump(
      tester,
      SizedBox(
        width: 240,
        child: PrimaryButton(label: 'Expandir', expand: true, onPressed: () {}),
      ),
    );

    expect(tester.getSize(find.byType(PrimaryButton)).width, 240);
  });

  testWidgets('renders the optional icon', (WidgetTester tester) async {
    await _pump(
      tester,
      PrimaryButton(label: 'Adicionar', icon: Icons.add, onPressed: () {}),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('lays out inside an unbounded-width Row without asserting', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      Row(
        children: [PrimaryButton(label: 'Registrar', onPressed: () {})],
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Registrar'), findsOneWidget);
  });

  testWidgets('enabled button gets the CTA shadow token', (
    WidgetTester tester,
  ) async {
    await _pump(tester, PrimaryButton(label: 'Registrar', onPressed: () {}));

    final decoration = _shadowDecoration(tester);
    expect(decoration, isNotNull);
    expect(decoration?.boxShadow, ReparaShadows.cta);
    expect(decoration?.borderRadius, BorderRadius.circular(ReparaRadii.pill));
  });

  testWidgets('disabled and loading buttons have no CTA shadow', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const PrimaryButton(label: 'Desabilitado'));
    expect(_shadowDecoration(tester), isNull);

    await _pump(
      tester,
      PrimaryButton(label: 'Enviando', isLoading: true, onPressed: () {}),
    );
    expect(_shadowDecoration(tester), isNull);
  });

  testWidgets('announces the loading state as a live region', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await _pump(
      tester,
      PrimaryButton(label: 'Enviar', isLoading: true, onPressed: () {}),
    );

    final semantics = tester.getSemantics(
      find.bySemanticsLabel(RegExp('Carregando')),
    );
    expect(semantics.getSemanticsData().flagsCollection.isLiveRegion, isTrue);

    handle.dispose();
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
      PrimaryButton(
        label: 'Registrar nova ocorrência no mapa',
        expand: true,
        onPressed: () {},
      ),
      textScale: 2.0,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThan(ReparaSizes.primaryButtonHeight),
    );
  });
}

BoxDecoration? _shadowDecoration(WidgetTester tester) {
  final boxes = tester.widgetList<DecoratedBox>(
    find.descendant(
      of: find.byType(PrimaryButton),
      matching: find.byType(DecoratedBox),
    ),
  );
  for (final box in boxes) {
    final decoration = box.decoration;
    if (decoration is BoxDecoration &&
        decoration.boxShadow != null &&
        decoration.boxShadow!.isNotEmpty) {
      return decoration;
    }
  }
  return null;
}

class _LoadingHarness extends StatefulWidget {
  const _LoadingHarness({super.key});
  @override
  State<_LoadingHarness> createState() => _LoadingHarnessState();
}

class _LoadingHarnessState extends State<_LoadingHarness> {
  int taps = 0;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Enviar',
      isLoading: _loading,
      onPressed: () {
        taps += 1;
        setState(() => _loading = true);
      },
    );
  }
}
