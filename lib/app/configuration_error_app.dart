import 'package:flutter/material.dart';
import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';

/// Root app shown when the configuration is invalid: either a bad
/// `--dart-define` value ([AppConfigError]) or a release build without
/// `MOCK_MODE=true`.
///
/// Deliberately minimal — a plain [MaterialApp] with no routes and no extra
/// localization delegates — because it exists precisely for setups where the
/// rest of the app cannot be trusted to build. It must never render anything
/// that looks like real app data.
///
/// The body stays centered when it fits and scrolls when it does not (e.g.
/// the ~300-char release message at large text scales on small screens), so
/// the explanation of the configuration failure is never clipped.
class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key, required this.message});

  /// pt-BR message explaining the configuration problem.
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repara',
      theme: AppTheme.light,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(ReparaSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: ReparaColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: ReparaSpacing.md),
                    Semantics(
                      header: true,
                      child: Text(
                        'Configuração inválida',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: ReparaSpacing.sm),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: ReparaColors.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
