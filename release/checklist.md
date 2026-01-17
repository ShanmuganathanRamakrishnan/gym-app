# Release Checklist

Pre-release verification steps before App Store / Play Store submission.

## Code & Build

- [ ] All lints pass (`flutter analyze`)
- [ ] All tests pass (`flutter test`)
- [ ] Backend builds without errors (`npm run build`)
- [ ] Backend tests pass (`npm test`)
- [ ] App runs on iOS simulator
- [ ] App runs on Android emulator
- [ ] App runs on physical iOS device
- [ ] App runs on physical Android device

## Core User Flow Smoke Test

- [ ] Launch app → Auth screen loads
- [ ] Onboarding carousel auto-advances
- [ ] Can switch between Login/Signup
- [ ] Form validation works (empty fields, invalid email)
- [ ] Successful login navigates to Home
- [ ] Bottom navigation works (all 4 tabs)
- [ ] Home screen displays workout card
- [ ] Quick start cards are tappable
- [ ] Recent workouts list renders
- [ ] Profile screen shows stats
- [ ] Sign out works

## Backend Verification

- [ ] `docker-compose up -d` starts all services
- [ ] Health check passes (`curl localhost:3845/health`)
- [ ] GET `/design-spec` returns JSON
- [ ] GET `/ui/home` returns screen data
- [ ] Rate limiting works (test with 61+ requests/minute)

## Security

- [ ] No hardcoded secrets in codebase
- [ ] `.env` files are gitignored
- [ ] HTTPS configured for production API
- [ ] JWT secret is rotated
- [ ] API keys use environment variables

## Privacy & Compliance

- [ ] Privacy policy URL is live and accessible
- [ ] Privacy policy linked in app settings
- [ ] GDPR: data export endpoint works
- [ ] GDPR: data deletion endpoint works
- [ ] Health disclaimers present if applicable

## Store Requirements

- [ ] App icons for all required sizes
- [ ] Screenshots for all required device sizes
- [ ] App description written
- [ ] Keywords/tags selected
- [ ] Age rating questionnaire completed
- [ ] IAP products configured (if applicable)
- [ ] Review notes prepared

## Environment

- [ ] Production environment variables set
- [ ] Sentry DSN configured
- [ ] Database migrated and seeded
- [ ] Object storage configured

## Final Steps

- [ ] Version number incremented
- [ ] Build number incremented
- [ ] Changelog updated
- [ ] Release notes written
- [ ] Build archive created
- [ ] Submitted for review
