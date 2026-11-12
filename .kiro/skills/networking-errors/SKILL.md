---
name: networking-errors
description: Centralized HTTP client, connectivity, serialization, timeout, and typed failure handling.
---

# Networking and errors

- Reuse the project's existing HTTP library. If none exists, propose Dio or `package:http` with tradeoffs.
- Configure base URL, timeouts, interceptors, user-agent/app version headers centrally.
- Keep interceptors deterministic and avoid recursive refresh loops.
- Parse server error bodies defensively; malformed error JSON must not crash the app.
- Preserve safe diagnostic context without exposing secrets or personal data.
- Distinguish no connection, timeout, cancelled request, malformed response, unauthorized, forbidden, not found, conflict, validation, rate limit, server error, and unknown.
- Only map status codes according to the actual Java API contract.
