/// Named route paths for the app.
///
/// Leaf module: it has no imports so both the router and the pages can depend
/// on it without creating an `app_router` <-> page import cycle.
abstract final class AppRoutes {
  /// Map — entry screen.
  static const String map = '/';

  /// New report flow — step 1 of 3 (capture).
  static const String reportCapture = '/report/capture';

  /// New report flow — step 2 of 3 (details).
  static const String reportDetails = '/report/details';

  /// New report flow — step 3 of 3 (review).
  static const String reportReview = '/report/review';

  /// New report flow — success screen.
  static const String reportSuccess = '/report/success';

  /// Developer-only design-system gallery (registered in debug builds only).
  static const String designSystem = '/dev/design-system';
}
