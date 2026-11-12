// Phase 1 widget tests for AppSkeleton: size, radius, semantics and the
// deliberately static (non-animated) placeholder.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/core/widgets/app_skeleton.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('renders the requested size, radius and color', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const AppSkeleton(
        width: 120,
        height: 16,
        borderRadius: BorderRadius.all(Radius.circular(ReparaRadii.md)),
      ),
    );

    expect(tester.getSize(find.byType(AppSkeleton)), const Size(120, 16));

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(AppSkeleton),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration;
    expect(decoration, isA<BoxDecoration>());

    final boxDecoration = decoration as BoxDecoration;
    expect(boxDecoration.color, ReparaColors.skeletonBase);
    expect(
      boxDecoration.borderRadius,
      const BorderRadius.all(Radius.circular(ReparaRadii.md)),
    );
    expect(
      boxDecoration.border,
      Border.all(
        color: AppTheme.light.colorScheme.outline,
        width: ReparaSizes.hairline,
      ),
    );
  });

  testWidgets('fills the available width when width is null', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const SizedBox(width: 200, child: AppSkeleton(height: 12)),
    );

    expect(tester.getSize(find.byType(AppSkeleton)).width, 200);
  });

  testWidgets('announces the optional semantic label as a live region', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await _pump(
      tester,
      const AppSkeleton(height: 16, semanticLabel: 'Carregando conteúdo'),
    );

    final semantics = tester.getSemantics(
      find.bySemanticsLabel('Carregando conteúdo'),
    );
    expect(semantics.getSemanticsData().flagsCollection.isLiveRegion, isTrue);

    handle.dispose();
  });

  testWidgets('adds no semantics noise when no label is provided', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await _pump(tester, const AppSkeleton(height: 16));

    expect(find.bySemanticsLabel(RegExp(r'.+')), findsNothing);

    handle.dispose();
  });

  testWidgets('is static, so pumpAndSettle completes', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const AppSkeleton(height: 16));

    await tester.pumpAndSettle();

    expect(find.byType(AppSkeleton), findsOneWidget);
  });
}
