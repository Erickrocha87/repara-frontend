import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/app.dart';

/// Pumps [child] (default [ReparaApp]) inside a [ProviderScope] with
/// [overrides].
Future<void> pumpApp(
  WidgetTester tester, {
  Widget? child,
  List<Override> overrides = const <Override>[],
}) async {
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: child ?? const ReparaApp()),
  );
}
