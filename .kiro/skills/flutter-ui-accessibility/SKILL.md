---
name: flutter-ui-accessibility
description: Flutter screen and widget implementation with responsive layouts, accessibility, and consistent design tokens.
---

# Flutter UI and accessibility

- Inspect the existing theme, spacing, typography, colors, and component library first.
- Prefer theme tokens over hardcoded repeated values.
- Handle small screens, landscape where relevant, safe areas, keyboard insets, and large text scaling.
- Avoid fixed heights around text unless overflow is intentionally handled.
- Provide semantic labels for icon-only controls and meaningful accessibility semantics.
- Ensure touch targets are practical and focus order makes sense.
- Every async screen should define loading, success, empty, and error states.
- Use ListView.builder/GridView.builder for unbounded collections.
- Add widget tests for important interaction and state transitions.
