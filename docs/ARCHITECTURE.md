# Frontend architecture baseline

## Scope
This repository contains the Flutter client only. Java owns business rules, persistence, authorization, and API behavior.

## Recommended feature-first layout

```text
lib/
  app/
    app.dart
    bootstrap.dart
    router/
    theme/
  core/
    config/
    network/
    errors/
    logging/
    widgets/
  features/
    <feature>/
      data/
        datasources/
        dto/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      application/
        controllers/
        providers/
      presentation/
        pages/
        widgets/
```

This is a target shape, not a mandate to restructure a working codebase. For small features, omit layers that add no value.

## As implemented (Phase 0, 2026-11-11)

The Phase 0 code follows the target shape above:

```text
lib/
  main.dart                      # entry point; delegates to bootstrap
  app/
    app.dart                     # ReparaApp (MaterialApp.router, pt_BR)
    bootstrap.dart               # ProviderScope + config load + error containment
    configuration_error_app.dart # fallback UI when AppConfig.fromEnvironment fails
    router/app_router.dart       # AppRoutes, appRouterProvider, buildAppRouter
    theme/                       # tokens, typography, app_theme
  core/
    config/app_config.dart       # MOCK_MODE/MOCK_SCENARIO dart-defines, release guard
  features/
    map/presentation/pages/map_page.dart
    report/presentation/pages/   # capture, details, review, success (Phase 0 stubs)
```

Report flow routes (`/report/capture`, `/report/details`, `/report/review`,
`/report/success`) are declared as children of `/` so the flow pages show a back
affordance over the map page.

## Dependency direction

`presentation -> application -> domain`
`data -> domain`
`app/bootstrap -> concrete implementations`

Domain must not import Flutter UI, HTTP clients, or serialization libraries.

## Defaults to decide explicitly
Decided for this project on 2026-11-11 (Phase 0); rationale in `docs/DEPENDENCIES.md` and spec §6.1:

- State management: Riverpod (`flutter_riverpod` 3.5.0). Controllers/providers live in `features/<feature>/application/` as features gain state.
- Navigation: go_router 18.1.4 (declarative, guarded routes in `lib/app/router/`).
- HTTP: none yet. The backend does not exist; no client is added until `docs/API_CONTRACT.md` documents endpoints.
- Test doubles: hand-written fakes for app-facing services; dev-only `mocktail` for impractical cases (approved deviation).
- Environment configuration: compile-time `--dart-define` (`MOCK_MODE`, `MOCK_SCENARIO`) for non-secret values, validated at startup by `AppConfig.fromEnvironment`; mock mode is refused in release builds. No client-side secret storage.
- Locale: `pt_BR` with `flutter_localizations`/`intl`.

Still to decide explicitly in later phases: serialization approach (only once a network contract exists), map/camera/location implementation (styled `CustomPaint` + fake services in the MVP).
