import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repara/app/router/app_router.dart';
import 'package:repara/app/theme/app_theme.dart';

/// Root widget of the Repara app.
///
/// Single-locale pt-BR app (spec assumption A2): the locale is pinned to
/// `pt-BR` and the SDK globalization delegates are supplied so Material
/// widgets (tooltips, back button, etc.) render in pt-BR. App-level message
/// localization (arb files) is intentionally deferred; user-facing strings
/// are pt-BR literals for now.
class ReparaApp extends ConsumerWidget {
  const ReparaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Repara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
