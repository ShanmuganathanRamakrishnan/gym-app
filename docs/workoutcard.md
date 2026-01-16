# WorkoutCard

Displays workout information with progress and CTA.

## Props

| Prop | Type | Description |
|------|------|-------------|
| title | string | The workout name |
| subtitle | string | Short description (e.g., muscle groups) |
| progress | number | 0..1 completion value |
| ctaLabel | string | Button text |

## Variants

- **notStarted** - Accent color, play icon
- **inProgress** - Orange color, pause icon, shows progress bar
- **completed** - Green color, check icon

## States

- Default
- Loading
- Disabled

## Notes

- CTA should be the primary action (Start / Resume / View)
- Progress bar only visible when progress > 0
- Provide loading/disabled states in UI
- Card uses 16px border radius
