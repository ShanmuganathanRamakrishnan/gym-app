# UI Guardrails – Gym App (NON-NEGOTIABLE)

## Color System
- Background: #0E0E0E (AppColors.background)
- Surface (cards only): #1A1A1A
- Accent: #FC4C02
- Text Primary: #FFFFFF
- Text Secondary: #9E9E9E

## Forbidden UI Patterns
- Grey AppBars
- Grey BottomNavigationBar
- Theme-derived navigation colors
- Small or visually weak graphs
- Flat screens with no visual hierarchy

## Navigation Rules
- BottomNavigationBar must explicitly define:
  - backgroundColor
  - selectedItemColor
  - unselectedItemColor
  - type = fixed

## Visual Hierarchy
- Each screen must have a primary visual anchor
- Primary visuals must dominate the screen
- Graphs/heatmaps must never look “compressed”

## Spacing System
- Allowed spacing: 8 / 16 / 24 / 32 only
- Consistent padding across screens

## Change Discipline
- UI-only tasks must not modify logic or services
- If unsure, STOP and ask before implementing
