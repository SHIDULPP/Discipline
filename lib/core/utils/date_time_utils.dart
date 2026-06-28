import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/entities/task_state.dart';

/// Calendar and task-state helpers shared across features.
abstract final class DateTimeUtils {
  static TaskState resolveState({
    required DateTime startTime,
    required Duration completionDuration,
    required bool isCompleted,
    DateTime? now,
  }) {
    if (isCompleted) return TaskState.completed;

    final current = now ?? DateTime.now();
    final endTime = startTime.add(completionDuration);

    if (current.isBefore(startTime)) return TaskState.upcoming;
    if (current.isBefore(endTime)) return TaskState.running;
    return TaskState.overdue;
  }

  /// Strips time components for calendar-day comparisons.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isScheduledToday(DateTime startTime, DateTime now) =>
      isSameDay(startTime, now);

  static bool isOverdue(Task task, {DateTime? now}) {
    if (task.isCompleted) return false;
    final current = now ?? DateTime.now();
    return current.isAfter(task.startTime.add(task.completionDuration));
  }
}
