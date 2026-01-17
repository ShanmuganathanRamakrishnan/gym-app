# Auth

Authentication and onboarding flow.

## Components

### OnboardingCarousel
- 3 slides with image, title, subtitle
- Auto-advances every 3500ms
- Manual swipe resets timer
- Dots indicator with accent color

### AuthForm
- Login: email + password
- Signup: name + email + password
- Client-side validation
- Loading state on submit

## Validation Rules

| Field | Rule |
|-------|------|
| Email | Non-empty, contains @ |
| Password | Min 6 characters |
| Name | Non-empty (signup only) |

## Navigation

- Initial route: /auth
- On success: redirect to /home

## Notes

- Social buttons are UI-only placeholders
- Touch targets >= 44px
- Forms use surface background
