# Orchestrated workflow

## Feature/bug lifecycle
1. Orchestrator reads `AGENTS.md`, relevant docs, and current implementation.
2. `project-scout` maps unknown areas.
3. `api-contract` checks backend facts if the task touches HTTP.
4. Orchestrator writes a short implementation plan and acceptance criteria.
5. `flutter-engineer` implements a bounded task and adds tests.
6. `ui-reviewer` reviews presentation/architecture; `security-reviewer` reviews auth/privacy/network-sensitive work.
7. `qa-engineer` executes gates and reports PASS/FAIL/NOT RUN with evidence.
8. Orchestrator inspects diff, resolves findings, and reports completion.

## Context preservation
For work spanning sessions, update:
- `docs/ARCHITECTURE.md` for stable architecture decisions.
- `docs/API_CONTRACT.md` for verified backend contract changes.
- `docs/WORKFLOW.md` only when team workflow changes.
- `AGENTS.md` only for durable engineering rules.

Do not dump transient task history into `AGENTS.md`. Use Git commits and concise task notes instead.

## Human approval required
- Adding/removing/upgrading dependencies with breaking or security impact.
- Changing authentication, storage, permissions, or API contracts.
- Deleting/moving large parts of the codebase.
- Running destructive commands, publishing, deploying, or pushing.
