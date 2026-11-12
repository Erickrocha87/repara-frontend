# Dependency decision record

This harness intentionally does not replace your `pubspec.yaml`.

Potential baseline choices (confirm existing packages and versions before adding):
- `dio` OR `http`: HTTP client; choose one.
- `flutter_riverpod`: only if Riverpod is selected for state management.
- `go_router`: only if go_router is selected for navigation.
- `flutter_secure_storage`: only if the documented auth flow requires persistent credential storage.
- `mocktail` OR `mockito`: test doubles; choose one.
- `integration_test`: Flutter SDK package for integration tests.

Do not install all candidates automatically. Ask the orchestrator to inspect `pubspec.yaml`, Flutter/Dart versions, and current architecture, then propose a minimal compatible set.

## Resolved for this project (2026-11-11, Phase 0)

Environment: Flutter 3.47.1 · Dart 3.13.1 (stable). Versions below are resolved versions
from `pubspec.lock`, not only `pubspec.yaml` constraints.

| Package | Resolved | Type | Justification |
|---|---|---|---|
| `flutter_riverpod` | 3.5.0 | direct, runtime | State management approved in `docs/IMPLEMENTATION_SPEC.md` §6.1: testable, `AsyncValue`, compile-safe overrides. Pulls transitive `riverpod` 3.5.0. |
| `go_router` | 18.1.4 | direct, runtime | Declarative routing approved in spec §6.1: guards and future deep links. |
| `intl` | 0.20.3 | direct, runtime | Required by `flutter_localizations` for the `pt_BR` locale. |
| `flutter_localizations` | SDK | direct, runtime | `pt_BR` Material localizations (back-button tooltip, etc.). SDK package; registered in `pubspec.yaml` per spec. |
| `cupertino_icons` | 1.0.9 | direct, runtime | Flutter template default; currently unused. Not removed in Phase 0 to keep the diff minimal; removal candidate for a later phase. |
| `flutter_test` | SDK | dev | Unit/widget tests. |
| `flutter_lints` | 6.0.0 | dev | Baseline analysis rules; already present in the template. |
| `mocktail` | 1.0.5 | dev | Approved deviation, see below. |
| `integration_test` | SDK | dev | Registered for later phases; no integration tests yet. |

Assets, not packages: `assets/fonts/Sora.ttf` (SIL OFL) is registered as the `Sora`
font family in the `pubspec.yaml` `fonts:` section and selected with `fontVariations`
in `lib/app/theme/typography.dart` (variable font weight), not installed as a font
package.

Deliberately not added: `dio`/`http` (no backend; no speculative endpoints),
`json_serializable`/`freezed` (no network serialization yet), `flutter_secure_storage`
(no auth flow yet), `camera`/`geolocator` (MVP uses fake capture/location services),
`flutter_map` (styled `CustomPaint` map). See spec §6.1.

### Deviation: `mocktail`

Spec §Fase 0 originally said "não adicionar biblioteca de mocks" because app-facing
services would be hand-written fakes/spies. On 2026-11-11 the human approved adding
`mocktail` as a dev-only dependency. Hand-written fakes remain the default for
app-facing services (repositories, capture, location); `mocktail` is available for test
doubles where hand-rolling is impractical. No Phase 0 test uses it yet.
