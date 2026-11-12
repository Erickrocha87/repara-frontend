---
name: testing-strategy
description: Unit, widget, repository, and integration testing strategy for Flutter frontend changes.
---

# Testing strategy

- Unit test pure business logic, validators, mappers, and error translation.
- Repository/client tests use fake or mocked HTTP; assert method, path, headers, payload, and mapping against documented contracts.
- Widget tests verify user-visible behavior and loading/error/empty/success states.
- Integration tests cover critical end-to-end client flows when infrastructure is available.
- Tests should be deterministic, isolated, and independent of production services.
- Avoid tests that only assert implementation details.
- Add regression tests for every fixed bug when practical.
- Do not delete or weaken assertions to make CI green.
