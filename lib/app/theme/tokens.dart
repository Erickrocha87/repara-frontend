import 'package:flutter/material.dart';

/// Core color tokens for the Repara app.
///
/// Values come from the reference prototype. Phase 1 re-checked every token
/// against spec §5.1 and found no mismatch, and the shadows below against
/// §5.3. Intentional additions beyond §5.1, kept from Phase 0, are the
/// `statusOpen*`/`statusResolved*`/`statusRejected*` colors, [captureDivider],
/// [scrim] and the [errorDark]/[onErrorDark] Material 3 dark error pair used
/// by the capture theme. Phase 1 adds [focusRing], [focusRingOnCapture],
/// [skeletonBase] and [skeletonHighlight], all derived from the existing
/// palette — no new hues.
abstract final class ReparaColors {
  static const brandPrimary = Color(0xFF26684D);
  static const brandInk = Color(0xFF0E3B2C);
  static const brandSoft = Color(0xFFD9EEE5);

  /// Focus indicator for interactive components on light surfaces: the brand
  /// green, so the ring stays on-palette on the amber CTA and on cards.
  static const focusRing = brandPrimary;

  static const accentAmber = Color(0xFFF2A324);
  static const accentAmberPressed = Color(0xFFD98B14);

  static const canvas = Color(0xFFF5F7F6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEEF3EF);

  /// Skeleton shimmer base — reuses the muted surface neutral.
  static const skeletonBase = surfaceMuted;

  /// Skeleton shimmer highlight — a slightly lighter green-tinted neutral than
  /// [skeletonBase], derived from the palette (no new hue).
  static const skeletonHighlight = Color(0xFFF6F9F7);

  static const mapCanvas = Color(0xFFE8EDE9);
  static const mapBlock = Color(0xFFF2F5F2);
  static const mapBlockAlt = Color(0xFFDDE9E0);
  static const mapRoad = Color(0xFFFFFFFF);
  static const mapWater = Color(0xFFDCE9ED);

  static const ink = Color(0xFF1A2420);
  static const inkMuted = Color(0xFF66716B);
  static const border = Color(0xFFE1E7E2);

  static const statusOpenBackground = Color(0xFFE3F1E9);
  static const statusOpenForeground = Color(0xFF1F6B50);
  static const statusInProgressBackground = Color(0xFFE9E1FA);
  static const statusInProgressForeground = Color(0xFF5B3EA8);
  static const statusResolvedBackground = Color(0xFFE3ECF6);
  static const statusResolvedForeground = Color(0xFF1F5B8A);
  static const statusRejectedBackground = Color(0xFFF6E4E2);
  static const statusRejectedForeground = Color(0xFF9A3B32);

  static const markerBuraco = Color(0xFF1F5B8A);
  static const markerEsgoto = Color(0xFF985B04);
  static const markerDejeto = Color(0xFF26684D);
  static const markerPoste = Color(0xFF6B52A5);

  static const captureBackground = Color(0xFF1F2529);
  static const captureSurface = Color(0xFF2C353A);
  static const captureSurfaceAlt = Color(0xFF343E43);
  static const captureChip = Color(0xFF14181B);
  static const captureText = Color(0xFFF4F7F5);
  static const captureTextMuted = Color(0xFFA7B1AC);
  static const captureDivider = Color(0xFF3E4A4F);

  /// Focus indicator for interactive components on the dark capture surface:
  /// uses the capture text tone so it stays visible on [captureBackground] and
  /// [captureSurface].
  static const focusRingOnCapture = captureText;

  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF1F6B50);
  static const scrim = Color(0x66000000);

  /// Material 3 dark-scheme error pair, used by the capture (dark) theme; the
  /// §5.1 [error] tone is tuned for light surfaces.
  static const errorDark = Color(0xFFFFB4AB);
  static const onErrorDark = Color(0xFF690005);
}

abstract final class ReparaSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

abstract final class ReparaRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  /// Region selector corner radius (spec §5.4 Map: selector height 48,
  /// radius 14 — a rounded rectangle, not a pill).
  static const double selector = 14;
}

abstract final class ReparaSizes {
  static const double minTouchTarget = 48;
  static const double appBarHeight = 56;
  static const double primaryButtonHeight = 56;

  /// Primary button minimum width (Material's default 64 px floor, spec
  /// §5.4 CTA is sized by its content and horizontal padding).
  static const double primaryButtonMinWidth = 64;

  /// Solid keyboard-focus ring width used by buttons and focusable surfaces.
  static const double focusRingWidth = 2;

  static const double iconTile = 40;
  static const double mapMarkerWidth = 42;
  static const double mapMarkerHeight = 50;
  static const double mapMarkerBadge = 22;
  static const double captureShutter = 76;

  /// Status chip height (spec §5.4 Map: status chip height 24, pill radius).
  static const double statusChipHeight = 24;

  /// Step badge height, e.g. the capture screen "1 de 3" pill (spec §5.4
  /// Capture: pill ~64 x 28).
  static const double stepBadgeHeight = 28;

  /// Step badge minimum width (spec §5.4 Capture: pill ~64 x 28).
  static const double stepBadgeMinWidth = 64;

  /// Location/region selector pill height (spec §5.4 Map: selector height
  /// 48).
  static const double locationPillHeight = 48;

  /// Small icon size, e.g. the "+" glyph inside the "Registrar" CTA (spec
  /// §5.4 Map: CTA icon 20).
  static const double iconSm = 20;

  /// Hairline border/divider width (spec §5.4 Map: search button and card
  /// borders are 1 wide).
  static const double hairline = 1;
}

/// Motion duration tokens (spec §5.3: standard transitions run 180-220 ms
/// with easeOut and must respect `MediaQuery.disableAnimations`).
///
/// [fast] and [standard] sit inside that range; [slow] is an extended
/// duration (350 ms) for deliberately longer transitions, beyond the
/// standard range.
abstract final class ReparaDurations {
  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 350);
}

/// Elevation tokens (spec §5.3).
///
/// Phase 1 re-checked [cta] (`0 8 24 rgba(242,163,36,0.28)`) and [sheet]
/// (`0 -8 32 rgba(26,36,32,0.08)`) against §5.3: both match. [marker] is a
/// map-pin shadow with no §5.3 counterpart.
abstract final class ReparaShadows {
  static const cta = <BoxShadow>[
    BoxShadow(color: Color(0x47F2A324), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const sheet = <BoxShadow>[
    BoxShadow(color: Color(0x141A2420), blurRadius: 32, offset: Offset(0, -8)),
  ];

  static const marker = <BoxShadow>[
    BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
