import 'package:flutter/foundation.dart' show kReleaseMode, visibleForTesting;

/// Data scenario used by the mock layer.
///
/// Known future relocation: the spec's target tree (docs/IMPLEMENTATION_SPEC.md
/// §6.2) places the scenario under `features/demands/data/mock/mock_scenario.dart`
/// in Phase 2, next to `MockReparaRepository`. It lives here in Phase 0 because
/// there is no feature/data layer yet and the value is read at the configuration
/// boundary. Moving it is a documented Phase 2 task, not an API promise.
enum MockScenario { success, empty, error, slow }

/// Raised when compile-time configuration (`--dart-define`) is invalid.
///
/// Carries a pt-BR message safe for direct display on the configuration error
/// screen. Callers must not swallow it silently or log its raw contents.
final class AppConfigError implements Exception {
  const AppConfigError(this.message);

  /// Human-readable pt-BR description naming the offending value and the
  /// accepted ones.
  final String message;

  @override
  String toString() => 'AppConfigError: $message';
}

/// Compile-time application configuration, read via `--dart-define`.
///
/// Como usar:
///
/// - `flutter run` — build de debug: `MOCK_MODE` assume `true` (o padrão
///   `_defaultMockMode` é `!kReleaseMode`) e o cenário assume `success`.
/// - `flutter run --dart-define=MOCK_SCENARIO=empty` — mesmo modo mock, mas
///   com o cenário vazio; outros valores aceitos: `error`, `slow`.
/// - Build de demonstração em release:
///   `flutter build apk --release --dart-define=MOCK_MODE=true`.
/// - `MOCK_MODE=false` (padrão em release) falha de propósito com uma tela de
///   configuração: o backend não existe, então não há fonte de dados, e dados
///   mockados nunca devem ser apresentados como reais.
///
/// Os valores são lidos com `*.fromEnvironment`, ou seja, resolvidos em tempo
/// de compilação; não há como alterá-los em runtime.
final class AppConfig {
  const AppConfig({required this.mockMode, required this.mockScenario});

  /// Whether the app runs on mock data. Release builds (demo builds) must
  /// opt in explicitly with `--dart-define=MOCK_MODE=true`; otherwise the
  /// bootstrap shows a configuration error instead of the app.
  final bool mockMode;

  /// Mock scenario selected at compile time.
  final MockScenario mockScenario;

  /// Default for [mockModeDefine]: mock data is allowed in debug/profile
  /// builds and rejected in release builds.
  static const bool _defaultMockMode = !kReleaseMode;

  /// Value of `--dart-define=MOCK_MODE` (default: [_defaultMockMode]).
  static const bool mockModeDefine = bool.fromEnvironment(
    'MOCK_MODE',
    defaultValue: _defaultMockMode,
  );

  /// Value of `--dart-define=MOCK_SCENARIO` (default: `'success'`).
  static const String mockScenarioDefine = String.fromEnvironment(
    'MOCK_SCENARIO',
    defaultValue: 'success',
  );

  /// Builds the configuration from the compiled-in `--dart-define` values.
  factory AppConfig.fromEnvironment() => AppConfig.fromDefines(
    mockMode: mockModeDefine,
    scenarioName: mockScenarioDefine,
  );

  /// Builds a configuration from explicit values (test seam for the parsing
  /// rules used by [fromEnvironment]).
  ///
  /// Throws [AppConfigError] when [scenarioName] is not one of the accepted
  /// scenario names (`success`, `empty`, `error`, `slow`).
  @visibleForTesting
  factory AppConfig.fromDefines({
    required bool mockMode,
    required String scenarioName,
  }) {
    final scenario = switch (scenarioName) {
      'success' => MockScenario.success,
      'empty' => MockScenario.empty,
      'error' => MockScenario.error,
      'slow' => MockScenario.slow,
      _ => throw AppConfigError(
        'Valor inválido para MOCK_SCENARIO: "$scenarioName". '
        'Valores aceitos: success, empty, error, slow (padrão: success).',
      ),
    };
    return AppConfig(mockMode: mockMode, mockScenario: scenario);
  }

  /// Message shown when a release build runs without
  /// `--dart-define=MOCK_MODE=true`.
  static const String releaseMockDisabledMessage =
      'Este aplicativo foi compilado em release sem '
      '--dart-define=MOCK_MODE=true. O backend do Repara ainda não existe, '
      'portanto não há fonte de dados para exibir. Para gerar uma build de '
      'demonstração, compile novamente com --dart-define=MOCK_MODE=true. Uma '
      'build de demonstração não deve ser distribuída como produção.';
}
