# Profile Screen Data Sources

This document describes the data sources and aggregation logic for the Profile screen.

## Overview

The Profile screen displays aggregated workout statistics, training focus, and recent workout history. All data is computed locally from the `WorkoutHistoryService` - no backend API calls are required.

## Data Flow

```
WorkoutHistoryService (SharedPreferences)
         │
         ▼
   ProfileRepository
         │
         ▼
    ProfileScreen
```

## Data Models

### ProfileAggregates

Top-level container for all profile data:

| Field | Type | Description |
|-------|------|-------------|
| `stats` | `ProfileStats` | Summary statistics |
| `streaks` | `StreakInfo` | Workout streak information |
| `trainingFocus` | `TrainingFocus?` | Primary muscle group focus (null if < 3 workouts) |
| `recentWorkouts` | `List<WorkoutHistoryEntry>` | Recent workout entries |

### ProfileStats

| Field | Type | Source |
|-------|------|--------|
| `totalWorkouts` | `int` | Count of `WorkoutHistoryEntry` items |
| `totalExercises` | `int` | Sum of `exerciseCount` across all entries |
| `totalSets` | `int` | Sum of `totalSets` across all entries |
| `totalMinutes` | `int` | Sum of `duration.inMinutes` across all entries |

### StreakInfo

| Field | Type | Calculation |
|-------|------|-------------|
| `currentStreak` | `int` | Consecutive days worked out ending today/yesterday |
| `longestStreak` | `int` | Maximum consecutive workout days ever |
| `lastWorkoutDate` | `DateTime?` | Most recent workout completion date |

### TrainingFocus

| Field | Type | Description |
|-------|------|-------------|
| `primaryMuscle` | `String` | Most trained muscle group |
| `percentage` | `double` | Percentage of workouts targeting this muscle |
| `muscleDistribution` | `Map<String, int>` | Distribution of all muscle groups |

> **Note:** Training focus currently uses placeholder data. Full implementation requires exercise-level muscle group tracking.

## Source Files

- `lib/services/profile_repository.dart` - Data aggregation logic
- `lib/services/workout_history_service.dart` - Persistent storage
- `lib/screens/profile_screen.dart` - UI implementation
- `lib/widgets/profile_*.dart` - Reusable profile widgets

## Widget Components

| Widget | Purpose |
|--------|---------|
| `ProfileHeader` | Avatar, username, quick stats (Workouts/Followers/Following) |
| `ProfileStatsRow` | Chart placeholder + Duration/Volume/Reps chips |
| `ProfileDashboard` | 2x2 tile grid (Statistics/Exercises/Measures/Calendar) |
| `TrainingFocusCard` | Primary muscle group display |
| `AICoachTeaserCard` | Coming soon teaser |

## Empty State Handling

When no workout history exists:
- Stats show 0 values
- Recent Workouts shows "No workouts yet" placeholder
- Training Focus shows "Not enough data"
- All widgets render without errors

## Future Improvements

1. **Training Focus**: Implement actual muscle group aggregation from exercise data
2. **Charts**: Replace placeholder with real sparkline/bar charts using `fl_chart`
3. **Followers/Following**: Integrate with backend social features
4. **Avatar**: Support custom avatar upload
