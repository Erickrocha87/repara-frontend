---
name: security-privacy
description: Mobile client security, secrets, token handling, privacy, permissions, and secure networking.
---

# Mobile security and privacy

- Treat all code and assets shipped in the app as inspectable.
- Never embed API keys, private keys, passwords, signing credentials, or backend secrets.
- Follow the Java API's documented auth protocol. Never invent refresh or logout endpoints.
- Use platform-appropriate secure storage for credentials if required by the documented threat model; ordinary preferences are not a secret vault.
- Do not log credentials, tokens, PII, or sensitive payloads.
- Do not bypass TLS validation or enable cleartext traffic as a convenience.
- Request OS permissions just in time and explain their purpose.
- Minimize collected and retained personal data.
- Backend authorization and input validation must be enforced server-side.
