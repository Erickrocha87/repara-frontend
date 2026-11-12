# Engineering Constitution — Flutter Frontend

## Mission
Build a reliable, accessible, maintainable Flutter application that consumes an independently developed Java backend. This repository owns the client only.

## Non-negotiable rules
1. Inspect the existing codebase before proposing or changing architecture.
2. Preserve established patterns unless there is a documented reason to change them.
3. Never invent API routes, request/response fields, status codes, auth flows, or business rules. Read `docs/API_CONTRACT.md` and available backend contract artifacts first. If missing, ask or create an explicit contract question list.
4. Keep UI, application state, domain logic, and infrastructure/API concerns separated.
5. Do not put HTTP calls, JSON parsing, or persistence logic directly in widgets.
6. Model loading, success, empty, and failure states explicitly.
7. Prefer small, cohesive, testable changes. Avoid unrelated refactors.
8. Use sound null safety. Avoid `dynamic`, `Object?` casts, `late` without a clear invariant, and `!` unless justified.
9. Never swallow exceptions. Translate infrastructure failures into typed application failures at the boundary.
10. Never log credentials, access tokens, personal data, or full sensitive payloads.
11. Never commit secrets, signing keys, keystores, `.env` files, or production configuration.
12. Do not change backend behavior or claim frontend validation proves backend correctness.

## Architecture defaults
Use the existing architecture if one exists. For new code, prefer feature-first organization with clear boundaries:
- `lib/app/`: app bootstrap, routing, theme, dependency composition.
- `lib/core/`: shared primitives, networking, errors, config, utilities.
- `lib/features/<feature>/presentation/`: screens, widgets, controllers/providers.
- `lib/features/<feature>/domain/`: entities, repository contracts, use cases when complexity justifies them.
- `lib/features/<feature>/data/`: DTOs, data sources, repository implementations.
Do not create abstraction layers that have no current use case.

## State and navigation
- Follow the state-management and routing libraries already present.
- If the project has no choice yet, propose Riverpod and go_router; do not silently add them.
- Keep state close to its owner; avoid global mutable state.
- Handle route guards and deep links deliberately.

## API boundary
- Centralize base URL, timeouts, headers, interceptors, serialization, and error mapping.
- Use typed DTOs at the network boundary and map to domain types where useful.
- Treat server responses as untrusted input; validate required fields and handle schema drift.
- Distinguish connectivity, timeout, unauthorized, forbidden, not-found, validation, rate-limit, server, and unknown failures where the contract supports it.
- Do not automatically retry non-idempotent requests.
- Refresh-token behavior must follow the Java backend contract; never assume a refresh endpoint.
- Use environment-specific configuration without embedding secrets in the client. Anything shipped in a mobile binary is extractable.

## Flutter quality
- Follow effective Dart and Flutter lints.
- Keep widgets focused and composable.
- Use `const` where appropriate.
- Avoid expensive work in `build`.
- Use keys for stateful list items when identity matters.
- Respect safe areas, text scaling, keyboard behavior, localization, and accessibility semantics.
- Do not hardcode colors, spacing, typography, or repeated strings when a theme/design token exists.

## Testing
- Add unit tests for domain logic and mappers.
- Add widget tests for meaningful UI behavior and states.
- Add repository/client tests with mocked HTTP responses.
- Test error and edge states, not only the happy path.
- Never claim a test passed unless its command was executed and its exit code was successful.

## Change protocol
Before editing:
1. Read relevant files and docs.
2. State the goal, assumptions, affected files, and risks.
3. Check existing conventions and tests.
4. For multi-file or architectural work, ask the orchestrator to produce a plan and wait for approval when scope is ambiguous.

After editing:
1. Run formatter.
2. Run analyzer.
3. Run relevant tests, then full tests when practical.
4. Run `tool/quality.sh` or `tool/quality.ps1` when feasible.
5. Inspect `git diff --check` and `git diff`.
6. Report commands actually run, results, limitations, and any manual verification needed.

## Forbidden
- No speculative endpoint implementation.
- No fake/mock production data presented as real.
- No broad file rewrites to make a small change.
- No dependency addition without explaining why and checking compatibility.
- No `// ignore`, analyzer suppression, test deletion, or weakened assertions without documented justification and explicit approval.
- No destructive shell command, deployment, release, git push, or external side effect without explicit human approval.
