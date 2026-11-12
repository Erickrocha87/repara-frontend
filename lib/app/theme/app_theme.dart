import 'package:flutter/material.dart';

import 'package:repara/app/theme/tokens.dart';
import 'package:repara/app/theme/typography.dart';

/// App themes.
///
/// Both themes are `static final` (built once) so repeated reads return the
/// same [ThemeData] instance instead of rebuilding on every access (L-4).
abstract final class AppTheme {
  /// Light theme used by the whole app except the capture screen.
  static final ThemeData light = _buildLight();

  /// Dark theme used only by the capture screen.
  static final ThemeData capture = _buildCapture();

  /// Solid 2 px focus ring. A low-alpha overlay is not used as the only focus
  /// cue: it is invisible on the amber CTA and on dark capture surfaces.
  static WidgetStateProperty<BorderSide?> _focusSide(Color color) {
    return WidgetStateProperty.resolveWith<BorderSide?>((states) {
      if (states.contains(WidgetState.focused)) {
        return BorderSide(color: color, width: ReparaSizes.focusRingWidth);
      }
      return null;
    });
  }

  /// Drops the Material overlay where the solid background or the focus side
  /// already communicates the state, avoiding a muddy low-alpha tint.
  static WidgetStateProperty<Color?> _solidFeedbackOverlay({
    required bool includePressed,
  }) {
    return WidgetStateProperty.resolveWith<Color?>((states) {
      final focused = states.contains(WidgetState.focused);
      final pressed = includePressed && states.contains(WidgetState.pressed);
      if (focused || pressed) {
        return Colors.transparent;
      }
      return null;
    });
  }

  static ThemeData _buildLight() {
    final textTheme = ReparaTypography.textTheme;
    const scheme = ColorScheme.light(
      primary: ReparaColors.brandPrimary,
      onPrimary: Colors.white,
      secondary: ReparaColors.accentAmber,
      onSecondary: ReparaColors.ink,
      surface: ReparaColors.surface,
      onSurface: ReparaColors.ink,
      onSurfaceVariant: ReparaColors.inkMuted,
      error: ReparaColors.error,
      onError: Colors.white,
      outline: ReparaColors.border,
      outlineVariant: ReparaColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ReparaColors.canvas,
      fontFamily: ReparaTypography.fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: ReparaColors.ink,
        titleTextStyle: textTheme.titleMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: ReparaColors.accentAmber,
              foregroundColor: ReparaColors.ink,
              disabledBackgroundColor: ReparaColors.border,
              disabledForegroundColor: ReparaColors.inkMuted,
              minimumSize: const Size(
                ReparaSizes.primaryButtonMinWidth,
                ReparaSizes.primaryButtonHeight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: ReparaSpacing.lg),
              elevation: 0,
              shape: const StadiumBorder(),
              // Colorless style: ButtonStyleButton applies foregroundColor on
              // top, so the CTA label follows the button state.
              textStyle: ReparaTypography.title,
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return ReparaColors.border;
                }
                if (states.contains(WidgetState.pressed)) {
                  return ReparaColors.accentAmberPressed;
                }
                return ReparaColors.accentAmber;
              }),
              overlayColor: _solidFeedbackOverlay(includePressed: true),
              side: _focusSide(ReparaColors.brandInk),
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: ReparaColors.brandPrimary,
              minimumSize: const Size.square(ReparaSizes.minTouchTarget),
              textStyle: ReparaTypography.labelLarge,
            ).copyWith(
              overlayColor: _solidFeedbackOverlay(includePressed: false),
              side: _focusSide(ReparaColors.brandPrimary),
            ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style:
            IconButton.styleFrom(
              foregroundColor: ReparaColors.ink,
              minimumSize: const Size.square(ReparaSizes.minTouchTarget),
            ).copyWith(
              overlayColor: _solidFeedbackOverlay(includePressed: false),
              side: _focusSide(ReparaColors.brandPrimary),
            ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ReparaColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ReparaSpacing.md,
          vertical: ReparaSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ReparaRadii.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ReparaRadii.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ReparaRadii.md),
          borderSide: const BorderSide(
            color: ReparaColors.focusRing,
            width: ReparaSizes.focusRingWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ReparaRadii.md),
          borderSide: const BorderSide(color: ReparaColors.error),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: ReparaColors.inkMuted,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: ReparaColors.inkMuted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ReparaColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ReparaRadii.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ReparaColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReparaRadii.md),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ReparaColors.border,
        thickness: ReparaSizes.hairline,
        space: ReparaSizes.hairline,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ReparaColors.brandPrimary,
      ),
    );
  }

  static ThemeData _buildCapture() {
    final textTheme = ReparaTypography.captureTextTheme;
    const scheme = ColorScheme.dark(
      primary: ReparaColors.accentAmber,
      onPrimary: ReparaColors.ink,
      secondary: ReparaColors.brandPrimary,
      onSecondary: Colors.white,
      surface: ReparaColors.captureSurface,
      onSurface: ReparaColors.captureText,
      onSurfaceVariant: ReparaColors.captureTextMuted,
      error: ReparaColors.errorDark,
      onError: ReparaColors.onErrorDark,
      outline: ReparaColors.captureDivider,
      outlineVariant: ReparaColors.captureDivider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: ReparaColors.captureBackground,
      fontFamily: ReparaTypography.fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: ReparaColors.captureText,
        titleTextStyle: textTheme.titleMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: ReparaColors.accentAmber,
              foregroundColor: ReparaColors.ink,
              disabledBackgroundColor: ReparaColors.border,
              disabledForegroundColor: ReparaColors.inkMuted,
              minimumSize: const Size(
                ReparaSizes.primaryButtonMinWidth,
                ReparaSizes.primaryButtonHeight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: ReparaSpacing.lg),
              elevation: 0,
              shape: const StadiumBorder(),
              textStyle: ReparaTypography.title,
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return ReparaColors.border;
                }
                if (states.contains(WidgetState.pressed)) {
                  return ReparaColors.accentAmberPressed;
                }
                return ReparaColors.accentAmber;
              }),
              overlayColor: _solidFeedbackOverlay(includePressed: true),
              side: _focusSide(ReparaColors.brandInk),
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: ReparaColors.captureText,
              minimumSize: const Size.square(ReparaSizes.minTouchTarget),
              textStyle: ReparaTypography.labelLarge,
            ).copyWith(
              overlayColor: _solidFeedbackOverlay(includePressed: false),
              side: _focusSide(ReparaColors.captureText),
            ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style:
            IconButton.styleFrom(
              foregroundColor: ReparaColors.captureText,
              minimumSize: const Size.square(ReparaSizes.minTouchTarget),
            ).copyWith(
              overlayColor: _solidFeedbackOverlay(includePressed: false),
              side: _focusSide(ReparaColors.captureText),
            ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ReparaColors.surface,
        contentTextStyle: ReparaTypography.textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReparaRadii.md),
        ),
      ),
    );
  }
}
