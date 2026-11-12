import 'package:flutter_test/flutter_test.dart';

import 'package:repara/core/config/app_config.dart';

void main() {
  group('AppConfig.fromEnvironment', () {
    test('defaults to mock mode enabled with the success scenario', () {
      final config = AppConfig.fromEnvironment();

      // `flutter test` runs in debug mode, so `!kReleaseMode` is true.
      expect(config.mockMode, isTrue);
      expect(config.mockScenario, MockScenario.success);
    });
  });

  group('AppConfig.fromDefines', () {
    test('maps every accepted scenario name', () {
      const scenariosByName = <String, MockScenario>{
        'success': MockScenario.success,
        'empty': MockScenario.empty,
        'error': MockScenario.error,
        'slow': MockScenario.slow,
      };
      scenariosByName.forEach((name, scenario) {
        final config = AppConfig.fromDefines(
          mockMode: true,
          scenarioName: name,
        );

        expect(config.mockScenario, scenario, reason: 'scenario "$name"');
        expect(config.mockMode, isTrue);
      });
    });

    test('rejects invalid scenario names with a clear message', () {
      const invalidNames = <String>['bogus', '', 'SUCCESS'];
      for (final name in invalidNames) {
        expect(
          () => AppConfig.fromDefines(mockMode: true, scenarioName: name),
          throwsA(
            isA<AppConfigError>().having(
              (error) => error.message,
              'message',
              allOf(
                contains('MOCK_SCENARIO'),
                contains(name),
                contains('success'),
                contains('empty'),
                contains('error'),
                contains('slow'),
              ),
            ),
          ),
          reason: 'invalid scenario "$name"',
        );
      }
    });
  });
}
