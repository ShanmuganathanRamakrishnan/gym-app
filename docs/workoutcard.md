# WorkoutCard

Hero card component for displaying today's workout.

## Props

| Name | Type | Description |
|------|------|-------------|
| title | string | Workout name |
| subtitle | string | Muscle groups |
| duration | string | Time (e.g., "45 min") |
| exercises | int | Number of exercises |
| progress | double | 0.0-1.0 completion |
| onStart | callback | Start button handler |

## Variants

- notStarted: Default state, progress = 0
- inProgress: Shows progress indicator
- completed: Full progress, muted CTA

## States

| State | Visual |
|-------|--------|
| Default | Orange CTA |
| Pressed | Dimmed accent |
| Disabled | Muted colors |

## Notes

- Uses surface background
- No shadow (dark mode)
- 16px border radius
- Minimum touch target 48px
