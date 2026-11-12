---
name: java-api-integration
description: Safe Flutter integration with a separately developed Java HTTP API using documented contracts only.
---

# Java API integration

- Read `docs/API_CONTRACT.md` and actual OpenAPI/schema sources before coding.
- Never guess URL paths, JSON keys, auth headers, pagination, or refresh-token behavior.
- Keep base URL and HTTP client configuration centralized.
- Keep DTO serialization at the data boundary; map to domain objects where useful.
- Set explicit connect/receive/send timeouts appropriate to the operation.
- Map transport, timeout, parse, auth, authorization, validation, rate-limit, server, and unknown errors.
- Do not retry non-idempotent operations automatically.
- Do not log tokens, passwords, full PII, or sensitive request/response bodies.
- Client-side validation improves UX but is not authorization; the Java backend must enforce permissions.
- Use mock HTTP adapters in tests. Never call production endpoints from unit/widget tests.
