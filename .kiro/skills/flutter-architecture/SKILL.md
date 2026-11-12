---
name: flutter-architecture
description: Feature-first Flutter architecture, boundaries, dependency direction, and maintainable composition.
---

# Flutter architecture

- First inspect the repository. Existing coherent architecture wins over a rewrite.
- For new features, prefer feature-first folders: `features/<feature>/{presentation,application,domain,data}` where useful.
- Keep widgets in presentation; orchestration/state in application; business rules in domain; HTTP/serialization in data/core.
- Dependency direction points inward. Domain must not depend on Flutter widgets, Dio, or JSON.
- Introduce repository interfaces only when they clarify a boundary or enable meaningful testing.
- Avoid speculative use-case classes for trivial pass-through behavior.
- Keep shared `core/` small; feature-specific code stays inside its feature.
- Document architectural decisions that affect multiple features.
