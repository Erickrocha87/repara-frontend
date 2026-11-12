// Phase 1 design-token tests: the §5.2 typography scale, the §5.2 -> Material
// TextTheme mapping, the §5.4 `labelLarge` extra, the L-4 theme caching, the
// solid focus rings, the CTA states/padding and the per-theme color schemes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/app/theme/typography.dart';

FontWeight _fontWeightFor(int weight) {
  return switch (weight) {
    400 => FontWeight.w400,
    500 => FontWeight.w500,
    600 => FontWeight.w600,
    700 => FontWeight.w700,
    _ => throw ArgumentError.value(weight, 'weight'),
  };
}

/// Asserts [style] matches a spec §5.2 row: [size] px, [lineHeight] px and
/// [weight], with Sora and the matching variable-font axis.
void _expectSpecStyle(
  TextStyle style, {
  required double size,
  required double lineHeight,
  required int weight,
}) {
  expect(style.fontFamily, 'Sora');
  expect(style.fontSize, size);
  expect(style.height, closeTo(lineHeight / size, 1e-9));
  expect(style.fontWeight, _fontWeightFor(weight));
  expect(style.fontVariations, <FontVariation>[
    FontVariation('wght', weight.toDouble()),
  ]);
}

/// Asserts [actual] carries the same metrics as [expected] and resolves to
/// [color]. The theme applies colors, so identity with the colorless named
/// style is intentionally not expected.
void _expectThemedStyle(
  TextStyle? actual,
  TextStyle expected, {
  required Color color,
}) {
  expect(actual, isNotNull);
  expect(actual?.fontFamily, expected.fontFamily);
  expect(actual?.fontSize, expected.fontSize);
  expect(actual?.fontWeight, expected.fontWeight);
  expect(actual?.fontVariations, expected.fontVariations);
  expect(actual?.height, expected.height);
  expect(actual?.color, color);
}

void _expectFocusSide(WidgetStateProperty<BorderSide?>? side, Color color) {
  expect(side, isNotNull);
  expect(
    side?.resolve(const <WidgetState>{WidgetState.focused}),
    BorderSide(color: color, width: ReparaSizes.focusRingWidth),
  );
  expect(side?.resolve(const <WidgetState>{}), isNull);
}

void _expectCtaBackground(ButtonStyle? style) {
  final background = style?.backgroundColor;
  expect(background, isNotNull);
  expect(background?.resolve(const <WidgetState>{}), ReparaColors.accentAmber);
  expect(
    background?.resolve(const <WidgetState>{WidgetState.pressed}),
    ReparaColors.accentAmberPressed,
  );
  expect(
    background?.resolve(const <WidgetState>{WidgetState.disabled}),
    ReparaColors.border,
  );
}

void main() {
  group('ReparaTypography §5.2 scale', () {
    test('matches the nine spec styles', () {
      _expectSpecStyle(
        ReparaTypography.display,
        size: 28,
        lineHeight: 34,
        weight: 700,
      );
      _expectSpecStyle(
        ReparaTypography.h1,
        size: 24,
        lineHeight: 30,
        weight: 700,
      );
      _expectSpecStyle(
        ReparaTypography.h2,
        size: 20,
        lineHeight: 26,
        weight: 600,
      );
      _expectSpecStyle(
        ReparaTypography.h3,
        size: 18,
        lineHeight: 24,
        weight: 600,
      );
      _expectSpecStyle(
        ReparaTypography.title,
        size: 16,
        lineHeight: 22,
        weight: 600,
      );
      _expectSpecStyle(
        ReparaTypography.body,
        size: 15,
        lineHeight: 22,
        weight: 400,
      );
      _expectSpecStyle(
        ReparaTypography.bodySmall,
        size: 13,
        lineHeight: 18,
        weight: 400,
      );
      _expectSpecStyle(
        ReparaTypography.label,
        size: 12,
        lineHeight: 16,
        weight: 600,
      );
      _expectSpecStyle(
        ReparaTypography.caption,
        size: 12,
        lineHeight: 16,
        weight: 500,
      );
    });

    test(
      'named styles are colorless so themes and buttons decide the color',
      () {
        expect(ReparaTypography.display.color, isNull);
        expect(ReparaTypography.title.color, isNull);
        expect(ReparaTypography.body.color, isNull);
        expect(ReparaTypography.labelLarge.color, isNull);
      },
    );

    test('maps the spec scale onto the Material TextTheme slots', () {
      final textTheme = ReparaTypography.textTheme;

      _expectThemedStyle(
        textTheme.displayLarge,
        ReparaTypography.display,
        color: ReparaColors.ink,
      );
      _expectThemedStyle(
        textTheme.headlineLarge,
        ReparaTypography.h1,
        color: ReparaColors.ink,
      );
      _expectThemedStyle(
        textTheme.headlineMedium,
        ReparaTypography.h2,
        color: ReparaColors.ink,
      );
      _expectThemedStyle(
        textTheme.titleLarge,
        ReparaTypography.h3,
        color: ReparaColors.ink,
      );
      _expectThemedStyle(
        textTheme.titleMedium,
        ReparaTypography.title,
        color: ReparaColors.ink,
      );
      _expectThemedStyle(
        textTheme.bodyLarge,
        ReparaTypography.body,
        color: ReparaColors.ink,
      );
      _expectThemedStyle(
        textTheme.bodyMedium,
        ReparaTypography.bodySmall,
        color: ReparaColors.ink,
      );
      _expectThemedStyle(
        textTheme.labelMedium,
        ReparaTypography.label,
        color: ReparaColors.ink,
      );
      _expectThemedStyle(
        textTheme.labelSmall,
        ReparaTypography.caption,
        color: ReparaColors.ink,
      );
    });

    test('labelLarge is the deliberate 14/600 §5.4 link extra', () {
      _expectSpecStyle(
        ReparaTypography.labelLarge,
        size: 14,
        lineHeight: 20,
        weight: 600,
      );
      _expectThemedStyle(
        ReparaTypography.textTheme.labelLarge,
        ReparaTypography.labelLarge,
        color: ReparaColors.ink,
      );
    });

    test('captureTextTheme recolors the scale for the dark surface', () {
      final capture = ReparaTypography.captureTextTheme;

      _expectThemedStyle(
        capture.bodyLarge,
        ReparaTypography.body,
        color: ReparaColors.captureText,
      );
      _expectThemedStyle(
        capture.displayLarge,
        ReparaTypography.display,
        color: ReparaColors.captureText,
      );
      expect(capture.bodyLarge?.fontSize, 15);
    });
  });

  group('AppTheme', () {
    test('light theme is built once (L-4)', () {
      expect(identical(AppTheme.light, AppTheme.light), isTrue);
      expect(identical(AppTheme.capture, AppTheme.capture), isTrue);
      expect(
        identical(ReparaTypography.textTheme, ReparaTypography.textTheme),
        isTrue,
      );
      expect(
        identical(
          ReparaTypography.captureTextTheme,
          ReparaTypography.captureTextTheme,
        ),
        isTrue,
      );
    });

    test('light FilledButton text keeps the 16/22 title line-height ratio', () {
      final textStyle = AppTheme.light.filledButtonTheme.style?.textStyle
          ?.resolve(const <WidgetState>{});

      expect(textStyle?.fontSize, 16);
      expect(textStyle?.height, closeTo(22 / 16, 1e-9));
      // Colorless so ButtonStyleButton's foregroundColor wins.
      expect(textStyle?.color, isNull);
    });

    test(
      'capture FilledButton text keeps the 16/22 title line-height ratio',
      () {
        final textStyle = AppTheme.capture.filledButtonTheme.style?.textStyle
            ?.resolve(const <WidgetState>{});

        expect(textStyle?.fontSize, 16);
        expect(textStyle?.height, closeTo(22 / 16, 1e-9));
        expect(textStyle?.color, isNull);
      },
    );

    test('color schemes expose the muted text and variant outline tokens', () {
      expect(
        AppTheme.light.colorScheme.onSurfaceVariant,
        ReparaColors.inkMuted,
      );
      expect(AppTheme.light.colorScheme.outlineVariant, ReparaColors.border);
      expect(
        AppTheme.capture.colorScheme.onSurfaceVariant,
        ReparaColors.captureTextMuted,
      );
      expect(
        AppTheme.capture.colorScheme.outlineVariant,
        ReparaColors.captureDivider,
      );
    });

    test('light buttons paint a solid 2 px focus ring', () {
      _expectFocusSide(
        AppTheme.light.filledButtonTheme.style?.side,
        ReparaColors.brandInk,
      );
      _expectFocusSide(
        AppTheme.light.textButtonTheme.style?.side,
        ReparaColors.brandPrimary,
      );
      _expectFocusSide(
        AppTheme.light.iconButtonTheme.style?.side,
        ReparaColors.brandPrimary,
      );
    });

    test('capture buttons paint a solid 2 px focus ring', () {
      _expectFocusSide(
        AppTheme.capture.filledButtonTheme.style?.side,
        ReparaColors.brandInk,
      );
      _expectFocusSide(
        AppTheme.capture.textButtonTheme.style?.side,
        ReparaColors.captureText,
      );
      _expectFocusSide(
        AppTheme.capture.iconButtonTheme.style?.side,
        ReparaColors.captureText,
      );
    });

    test(
      'focus and pressed overlays are transparent where solid cues exist',
      () {
        for (final theme in [AppTheme.light, AppTheme.capture]) {
          final filledOverlay = theme.filledButtonTheme.style?.overlayColor;
          expect(
            filledOverlay?.resolve(const <WidgetState>{WidgetState.focused}),
            Colors.transparent,
          );
          expect(
            filledOverlay?.resolve(const <WidgetState>{WidgetState.pressed}),
            Colors.transparent,
          );

          final textOverlay = theme.textButtonTheme.style?.overlayColor;
          expect(
            textOverlay?.resolve(const <WidgetState>{WidgetState.focused}),
            Colors.transparent,
          );

          final iconOverlay = theme.iconButtonTheme.style?.overlayColor;
          expect(
            iconOverlay?.resolve(const <WidgetState>{WidgetState.focused}),
            Colors.transparent,
          );
        }
      },
    );

    test('CTA background changes on press and disabled in both themes', () {
      _expectCtaBackground(AppTheme.light.filledButtonTheme.style);
      _expectCtaBackground(AppTheme.capture.filledButtonTheme.style);
    });

    test('CTA uses the §5.4 horizontal padding and minimum size', () {
      for (final theme in [AppTheme.light, AppTheme.capture]) {
        final style = theme.filledButtonTheme.style;
        expect(
          style?.padding?.resolve(const <WidgetState>{}),
          const EdgeInsets.symmetric(horizontal: ReparaSpacing.lg),
        );
        expect(
          style?.minimumSize?.resolve(const <WidgetState>{}),
          const Size(
            ReparaSizes.primaryButtonMinWidth,
            ReparaSizes.primaryButtonHeight,
          ),
        );
      }
    });

    test('text and icon buttons keep the 48 px touch target', () {
      for (final theme in [AppTheme.light, AppTheme.capture]) {
        expect(
          theme.textButtonTheme.style?.minimumSize?.resolve(
            const <WidgetState>{},
          ),
          const Size.square(ReparaSizes.minTouchTarget),
        );
        expect(
          theme.iconButtonTheme.style?.minimumSize?.resolve(
            const <WidgetState>{},
          ),
          const Size.square(ReparaSizes.minTouchTarget),
        );
      }
    });
  });
}
