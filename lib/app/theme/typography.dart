import 'package:flutter/material.dart';

import 'package:repara/app/theme/tokens.dart';

/// Typography scale for the app (spec §5.2).
///
/// Sora is bundled as a variable font; `fontVariations` selects the weight so
/// headings do not depend on synthetic bold.
///
/// Each spec style is exposed as a named [TextStyle] and mapped into
/// [textTheme]. [labelLarge] is the only style outside the §5.2 scale: it is a
/// deliberate extra backing the §5.4 green text links ("Trocar", "Ver lista").
abstract final class ReparaTypography {
  static const String fontFamily = 'Sora';

  /// display — 28/34, weight 700 (wordmark, impact titles).
  static final TextStyle display = _sora(
    size: 28,
    weight: 700,
    height: 34 / 28,
  );

  /// h1 — 24/30, weight 700 (screen title).
  static final TextStyle h1 = _sora(size: 24, weight: 700, height: 30 / 24);

  /// h2 — 20/26, weight 600 (section title).
  static final TextStyle h2 = _sora(size: 20, weight: 600, height: 26 / 20);

  /// h3 — 18/24, weight 600 (sheet/card title).
  static final TextStyle h3 = _sora(size: 18, weight: 600, height: 24 / 18);

  /// title — 16/22, weight 600 (card titles, app bar).
  static final TextStyle title = _sora(size: 16, weight: 600, height: 22 / 16);

  /// body — 15/22, weight 400 (running text).
  static final TextStyle body = _sora(size: 15, weight: 400, height: 22 / 15);

  /// bodySmall — 13/18, weight 400 (subtitles, addresses).
  static final TextStyle bodySmall = _sora(
    size: 13,
    weight: 400,
    height: 18 / 13,
  );

  /// label — 12/16, weight 600 (chips, badges, small buttons).
  static final TextStyle label = _sora(size: 12, weight: 600, height: 16 / 12);

  /// caption — 12/16, weight 500 (auxiliary text).
  static final TextStyle caption = _sora(
    size: 12,
    weight: 500,
    height: 16 / 12,
  );

  /// labelLarge — 14/20, weight 600.
  ///
  /// Deliberate extra, not part of the §5.2 scale: it backs the §5.4 green
  /// text links ("Trocar", "Ver lista", 14/600).
  static final TextStyle labelLarge = _sora(
    size: 14,
    weight: 600,
    height: 20 / 14,
  );

  /// Colorless base scale. Named styles above intentionally carry no color so
  /// they can be merged into buttons, where the button foreground color must
  /// win, and recolored per theme below.
  static final TextTheme _baseTextTheme = TextTheme(
    displayLarge: display,
    headlineLarge: h1,
    headlineMedium: h2,
    titleLarge: h3,
    titleMedium: title,
    bodyLarge: body,
    bodyMedium: bodySmall,
    labelLarge: labelLarge,
    labelMedium: label,
    labelSmall: caption,
  );

  /// Light-surface text theme: every slot resolves to the ink token.
  static final TextTheme textTheme = _baseTextTheme.apply(
    bodyColor: ReparaColors.ink,
    displayColor: ReparaColors.ink,
  );

  /// Dark capture-surface text theme: every slot resolves to the capture text
  /// token.
  static final TextTheme captureTextTheme = _baseTextTheme.apply(
    bodyColor: ReparaColors.captureText,
    displayColor: ReparaColors.captureText,
  );

  static TextStyle _sora({
    required double size,
    required int weight,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: _fontWeight(weight),
      fontVariations: <FontVariation>[FontVariation('wght', weight.toDouble())],
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static FontWeight _fontWeight(int weight) {
    return switch (weight) {
      <= 300 => FontWeight.w300,
      <= 400 => FontWeight.w400,
      <= 500 => FontWeight.w500,
      <= 600 => FontWeight.w600,
      _ => FontWeight.w700,
    };
  }
}
