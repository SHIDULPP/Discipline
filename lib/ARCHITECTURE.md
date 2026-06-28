# Discipline — Architecture

Offline Android habit-enforcement app built with **Flutter**, **Riverpod**, **Hive**, and **GoRouter**.

## Layer overview

```
lib/
├── app/              # Entry: bootstrap, MaterialApp, lifecycle
├── application/      # Cross-feature orchestration (coordinators)
├── core/             # Shared infra: theme, routing, errors, widgets
└── features/         # Feature modules (data → domain → presentation)
```

### Dependency rule

| Layer | May depend on |
|-------|----------------|
| `presentation` | `domain`, `application`, `core` |
| `application` | `domain`, `core` |
| `domain` | `core` (utilities only) |
| `data` | `domain`, `core` |

Domain never imports presentation. Coordinators live in `application/` because they span multiple bounded contexts.

## Features

| Feature | Responsibility |
|---------|----------------|
| `tasks` | CRUD, validation, task UI widgets |
| `settings` | User preferences, device permissions |
| `alarms` | Native exact-alarm scheduling |
| `accessibility` | Distraction-app blocking |
| `statistics` | Completion metrics from Hive tasks |
| `home` | Today dashboard (aggregates tasks) |

Recurring reminders are handled by the native alarm layer (`defaultReminderInterval` in settings), not a separate reminders module.

## State management

- **Riverpod** for DI and reactive streams.
- **Hive `watch()`** drives `tasksStreamProvider`, `settingsStreamProvider`, and `statisticsStreamProvider`.
- Platform services are bound once in `bootstrap()` via `ProviderContainer.overrides`.

## Error handling

1. Data layer throws typed `*Exception` (see `core/errors/exceptions.dart`).
2. `ExceptionMapper` converts exceptions → `Failure` for UI messages.
3. Screens use `AsyncErrorView` for consistent retry UX.
4. Mutations show `SnackBar` on failure where appropriate.

## Key types

- `TaskValidator` — single source for field validation rules.
- `DateTimeUtils` — task state machine + calendar helpers.
- `StatisticsCalculator` — pure statistics from task lists.
- `StaggeredEntrance` — shared list/form entrance animation.

## Testing

Run `flutter test`. Unit tests cover validators and statistics logic.

## Native integration

Android Kotlin handles exact alarms, accessibility enforcement, and battery-optimization checks via `DisciplinePlatformChannel`. Access platform APIs through feature repositories, not directly from widgets.
