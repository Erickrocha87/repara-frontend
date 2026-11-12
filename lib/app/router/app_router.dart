import 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, kDebugMode, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:repara/app/router/app_routes.dart';
import 'package:repara/app/router/route_error_page.dart';
import 'package:repara/dev/design_system_gallery.dart';
import 'package:repara/features/map/presentation/pages/map_page.dart';
import 'package:repara/features/report/presentation/pages/capture_page.dart';
import 'package:repara/features/report/presentation/pages/details_page.dart';
import 'package:repara/features/report/presentation/pages/review_page.dart';
import 'package:repara/features/report/presentation/pages/success_page.dart';

export 'package:repara/app/router/app_routes.dart';

/// Provides the app-wide [GoRouter].
///
/// Each `ProviderScope` (app or test) gets a lazily built router, so tests
/// can override it with a fresh instance per scenario.
final appRouterProvider = Provider<GoRouter>((ref) => buildAppRouter());

/// Reports a routing error only when a location actually matched.
///
/// An unknown location also reaches `errorBuilder` with an error (go_router's
/// "no routes for location" exception); that is expected and must not be
/// reported as a programming error. A matched location with an error is a real
/// failure, so it is forwarded to [FlutterError.reportError] instead of being
/// swallowed. Error details are never rendered by the UI.
@visibleForTesting
void reportMatchedRouteError(Object? error, String? fullPath) {
  if (error == null) {
    return;
  }
  if (fullPath == null || fullPath.isEmpty) {
    return;
  }
  FlutterError.reportError(
    FlutterErrorDetails(exception: error, library: 'repara.router'),
  );
}

/// Builds the app [GoRouter].
///
/// The report flow routes are nested under the map route so `go()` keeps the
/// map underneath the flow: the stack matches "map → report steps → back to
/// map" and the stub pages get an AppBar-implied back affordance. Full paths
/// remain exactly `/report/capture`, `/report/details`, `/report/review` and
/// `/report/success` (spec §6.3).
///
/// Deferred work, intentionally not implemented here:
/// - report flow guards (`ReviewPage` requires a complete draft,
///   `SuccessPage` requires a submission result) — Phase 5 per spec §6.3;
///   the pages wired here are Phase 0 stubs only.
///
/// The `/dev/design-system` gallery is registered only when both [kDebugMode]
/// and [includeDesignSystemGallery] are true, so release builds never expose
/// it. [includeDesignSystemGallery] is an explicit test seam; the
/// `kDebugMode` check is the release guard. Unknown locations render
/// [RouteErrorPage] with pt-BR copy instead of go_router's default English
/// error screen (L-5).
///
/// Navigation constraints for the report flow (Phases 4–5), recorded from
/// the independent UI review on 2026-11-11 so they cannot be lost:
/// - step-to-step navigation inside the flow must use push/pop (or a
///   dedicated flow shell), NOT `context.go`: `go()` rebuilds the stack to
///   [map, target], discarding the previous step, which would break "Voltar"
///   between steps (spec §8.3/§8.4);
/// - the final `SuccessPage` must suppress the automatic AppBar back
///   affordance when implemented (spec §6.3/§8.5): "Voltar ao mapa" is an
///   explicit `go('/')` plus draft cleanup, not a back stack.
GoRouter buildAppRouter({
  String initialLocation = AppRoutes.map,
  bool includeDesignSystemGallery = kDebugMode,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    errorBuilder: (context, state) {
      reportMatchedRouteError(state.error, state.fullPath);
      return RouteErrorPage(onGoHome: () => context.go(AppRoutes.map));
    },
    routes: [
      GoRoute(
        path: AppRoutes.map,
        name: 'map',
        builder: (context, state) => const MapPage(),
        routes: [
          GoRoute(
            path: 'report/capture',
            name: 'report-capture',
            builder: (context, state) => const CapturePage(),
          ),
          GoRoute(
            path: 'report/details',
            name: 'report-details',
            builder: (context, state) => const DetailsPage(),
          ),
          GoRoute(
            path: 'report/review',
            name: 'report-review',
            builder: (context, state) => const ReviewPage(),
          ),
          GoRoute(
            path: 'report/success',
            name: 'report-success',
            builder: (context, state) => const SuccessPage(),
          ),
        ],
      ),
      if (kDebugMode && includeDesignSystemGallery)
        GoRoute(
          // Top-level route paths must be absolute; go_router matches this
          // against `AppRoutes.designSystem` (`/dev/design-system`).
          path: AppRoutes.designSystem,
          name: 'design-system',
          builder: (context, state) => const DesignSystemGalleryPage(),
        ),
    ],
  );
}
