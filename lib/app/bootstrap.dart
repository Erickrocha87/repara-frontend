import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/widgets.dart' show Widget, runApp;
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:repara/app/app.dart';
import 'package:repara/app/configuration_error_app.dart';
import 'package:repara/core/config/app_config.dart';

/// Boots the Repara app.
///
/// Responsibilities:
///
/// - read the compile-time configuration ([AppConfig.fromEnvironment]);
/// - guard against invalid configuration: an [AppConfigError] (e.g. a bad
///   `--dart-define=MOCK_SCENARIO` value) must never leave the device with a
///   blank screen, nor be swallowed silently — it renders
///   [ConfigurationErrorApp] with the error message;
/// - guard release builds: without `--dart-define=MOCK_MODE=true` there is no
///   data source (the backend does not exist yet), so mock data must not be
///   presented as a real app — the configuration screen is shown instead;
/// - mount the Riverpod [ProviderScope] around [ReparaApp].
void bootstrap() => runApp(buildRootAppFromConfig(AppConfig.fromEnvironment));

/// Builds the root widget by loading the configuration through [loadConfig];
/// exposed for tests so the try/catch glue can be verified without [runApp].
///
/// Configuration failures are user-visible, not silent: an [AppConfigError]
/// thrown while loading is rendered as [ConfigurationErrorApp] with its
/// message instead of crashing with a blank screen. Other exception types are
/// intentionally not caught.
@visibleForTesting
Widget buildRootAppFromConfig(AppConfig Function() loadConfig) {
  try {
    return buildRootAppFor(loadConfig());
  } on AppConfigError catch (error) {
    return ConfigurationErrorApp(message: error.message);
  }
}

/// Builds the root widget for [config]; exposed for tests.
///
/// - `mockMode == true` → the real app ([ProviderScope] + [ReparaApp]).
/// - otherwise → [ConfigurationErrorApp]: a release build without
///   `--dart-define=MOCK_MODE=true` must fail loudly, never show a mock-ish
///   UI as real.
@visibleForTesting
Widget buildRootAppFor(AppConfig config) {
  if (config.mockMode) {
    return const ProviderScope(child: ReparaApp());
  }
  return const ConfigurationErrorApp(
    message: AppConfig.releaseMockDisabledMessage,
  );
}
