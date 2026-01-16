# Button

A primary interactive element for user actions.

## Props

| Prop | Type | Description |
|------|------|-------------|
| label | string | Button text |
| variant | enum | `primary`, `secondary`, `text` |
| disabled | boolean | Disables interaction |
| loading | boolean | Shows loading spinner |
| onPressed | callback | Action handler |

## Variants

- **primary** - Filled background with accent color
- **secondary** - Outlined with accent border
- **text** - No background, text-only

## States

- Default
- Hover (desktop)
- Pressed
- Disabled
- Loading

## Usage Notes

- Use primary for main CTA (e.g., "Start Workout")
- Use secondary for alternative actions
- Use text variant for less prominent actions
- Always provide meaningful labels for accessibility
