---
name: dependency-hygiene
description: Evaluates Flutter and Dart dependencies for necessity, compatibility, maintenance, and security.
---

# Dependency hygiene

Before proposing a package:
1. Check whether Flutter/Dart SDK or an existing package already solves the need.
2. Check compatibility with the project's Flutter and Dart constraints.
3. Check maintenance activity, license, transitive dependency impact, and platform support.
4. Explain why the dependency is needed and alternatives.
5. Ask for approval before adding or upgrading packages unless explicitly authorized.

- Prefer fewer dependencies and stable releases.
- Do not blindly run `flutter pub upgrade`.
- Commit `pubspec.lock` for applications.
- Review breaking changes and generated code requirements.
