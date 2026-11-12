---
name: dart-quality
description: Effective Dart, null safety, typing, formatting, error handling, and analyzer discipline.
---

# Dart quality

- Follow `analysis_options.yaml` and the project's SDK constraints.
- Prefer final/const, small functions, explicit public API types, and immutable value objects.
- Avoid `dynamic`, broad `Object` casts, forced unwraps, and unawaited futures.
- Use sealed/final classes or enums for finite state/error categories when supported by SDK.
- Keep exceptions at infrastructure boundaries; map them to typed failures.
- Do not catch and ignore exceptions.
- Do not add analyzer ignores without narrow justification and comments.
- Run `dart format`, `flutter analyze`, and relevant tests.
