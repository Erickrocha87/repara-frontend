# Definition of Done

A change is complete only when applicable items are satisfied:

- [ ] Acceptance criteria are met.
- [ ] Existing architecture and API contract are respected.
- [ ] No speculative endpoint, field, auth, or business rule was introduced.
- [ ] Loading, success, empty, and failure states are handled where relevant.
- [ ] Accessibility and responsive behavior were considered.
- [ ] Tests cover behavior and important edge cases.
- [ ] `dart format` check passes.
- [ ] `flutter analyze` passes.
- [ ] Relevant `flutter test` suite passes.
- [ ] `git diff --check` passes.
- [ ] No secrets or sensitive data are exposed/logged.
- [ ] Reviewer findings are resolved or explicitly accepted.
- [ ] Final response lists changed files, commands actually run, outcomes, and remaining risks.

A check that was not run is NOT RUN, never PASS.
