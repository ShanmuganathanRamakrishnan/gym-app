# UI Guardrails

## Layout Rules
1. **Scrollability**: All primary screens (Profile, Statistics, Details) must use `CustomScrollView` or `SingleChildScrollView` to prevent overflow on small devices.
2. **Headers**: Use `SliverAppBar` for headers that should scroll away. Avoid fixed `AppBar` unless the screen is a modal or simple detail view.
3. **Intrinsic Height**: Avoid `IntrinsicHeight` in lists. Use fixed or constrained heights (e.g., `SizedBox(height: 180)` for charts).

## Components
1. **Charts**: 
    - Must accept a `maxHeight` constraint.
    - Must handle empty data states gracefully (`No data` placeholder).
    - Bars/Points must have a minimum touch target or visual width (min 4px).
2. **Metric Cards**:
    - Do not duplicate data shown in headers.
    - Avoid grid layouts that break on narrow screens; use scrollable rows or wrapping if dynamic.

## Feature Flags
- **Promotional UI**: "AI Coach" or "Pro" cards found in Profile must be wrapped in a feature flag or check (currently removed for Layout Stability).
