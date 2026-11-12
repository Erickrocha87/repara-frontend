---
name: state-management
description: Guidance for predictable Flutter state ownership, async state, and repository integration.
---

# State management

- Follow the state library already used in the repository.
- If none exists, recommend Riverpod to the orchestrator; do not install it without approval.
- Separate ephemeral widget state from feature/application state.
- Keep state scoped to the feature/lifecycle that owns it.
- Model async states explicitly; avoid booleans that allow impossible combinations.
- Providers/controllers should orchestrate repositories, not perform raw HTTP or widget rendering.
- Dispose controllers, streams, and subscriptions correctly.
- Avoid global mutable singletons and hidden side effects during widget build.
- Test state transitions and failure cases.
