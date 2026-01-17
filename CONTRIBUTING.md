# Contributing to Gym App

Thank you for your interest in contributing!

## Coding Style

### Flutter (Dart)
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter format` before committing
- Run `flutter analyze` to catch issues
- Prefer `const` constructors where possible
- Use meaningful widget/variable names

### Backend (TypeScript)
- Follow ESLint configuration (`.eslintrc`)
- Use Prettier for formatting
- Prefer `async/await` over raw Promises
- Add JSDoc comments for public functions
- Use strict TypeScript (`strict: true`)

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting (no code change)
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples
```
feat(auth): add social login buttons
fix(workout): correct progress calculation
docs(readme): update setup instructions
```

## Branch Strategy

```
main        ← production-ready code
  │
  └── dev   ← integration branch
       │
       └── feature/auth-flow     ← feature branches
       └── feature/workout-card
       └── fix/progress-bar
```

### Rules
1. Never commit directly to `main`
2. Create feature branches from `dev`
3. Use descriptive branch names: `feature/`, `fix/`, `docs/`
4. Open PR to `dev`, get review, then merge
5. `dev` → `main` via release PR

## Pull Request Process

1. Update docs if behavior changes
2. Add/update tests for new features
3. Run all lints and tests locally
4. Request review from maintainer
5. Squash merge after approval

## Questions?

Open an issue with the `question` label.
