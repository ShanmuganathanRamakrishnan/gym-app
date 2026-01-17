# Regression Prevention

## Protected Files

The following files are protected by automated tests:

| File | Test | Purpose |
|------|------|---------|
| `design/design-spec.json` | `test/theme_token_test.dart` | Dark theme tokens |
| `docs/theme.md` | Manual review | Theme documentation |

## Theme Tokens (DO NOT CHANGE)

```json
{
  "background": "#0E0E0E",
  "accent": "#FC4C02"
}
```

## Before Changing Theme

1. Run the regression test: `dart test/theme_token_test.dart`
2. If changing tokens intentionally, update the test first
3. Get approval before merging

## Auth UI Files

These files implement the onboarding and authentication flow:
- `lib/auth_screen.dart`
- `lib/auth_widgets.dart`

Changes require review to ensure carousel and forms remain functional.
