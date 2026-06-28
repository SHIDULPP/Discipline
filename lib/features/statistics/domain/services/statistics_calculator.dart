import 'package:discipline/core/utils/date_time_utils.dart';
import 'package:discipline/features/statistics/domain/entities/period_progress_point.dart';
import 'package:discipline/features/statistics/domain/entities/task_statistics.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';

/// Pure, side-effect-free statistics derived from persisted tasks.
abstract final class StatisticsCalculator {
  static TaskStatistics compute(
    List<Task> tasks, {
    DateTime? from,
    DateTime? to,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final scoped = _filterByRange(tasks, from, to);

    final totalTasks = scoped.length;
    final completedTasks = scoped.where((task) => task.isCompleted).length;
    final overdueTasks =
        scoped.where((task) => DateTimeUtils.isOverdue(task, now: current)).length;
    final completionRate =
        totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return TaskStatistics(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      completionRate: completionRate,
      currentStreak: _currentStreak(tasks, current),
      longestStreak: _longestStreak(tasks),
      weeklyProgress: _buildDailyProgress(tasks, current, days: 7),
      monthlyProgress: _buildDailyProgress(tasks, current, days: 30),
    );
  }

  static List<Task> _filterByRange(
    List<Task> tasks,
    DateTime? from,
    DateTime? to,
  ) {
    if (from == null && to == null) return tasks;

    return tasks.where((task) {
      final day = DateTimeUtils.dateOnly(task.startTime);
      if (from != null && day.isBefore(DateTimeUtils.dateOnly(from))) {
        return false;
      }
      if (to != null && day.isAfter(DateTimeUtils.dateOnly(to))) return false;
      return true;
    }).toList(growable: false);
  }

  static List<PeriodProgressPoint> _buildDailyProgress(
    List<Task> tasks,
    DateTime now, {
    required int days,
  }) {
    final today = DateTimeUtils.dateOnly(now);
    return List.generate(days, (index) {
      final day = today.subtract(Duration(days: days - 1 - index));
      final dayTasks = _tasksForDay(tasks, day);
      return PeriodProgressPoint(
        date: day,
        totalTasks: dayTasks.length,
        completedTasks: dayTasks.where((task) => task.isCompleted).length,
      );
    });
  }

  static int _currentStreak(List<Task> tasks, DateTime now) {
    final firstDay = _earliestTaskDay(tasks);
    if (firstDay == null) return 0;

    var streak = 0;
    var day = DateTimeUtils.dateOnly(now);

    while (!day.isBefore(firstDay)) {
      final dayTasks = _tasksForDay(tasks, day);
      if (dayTasks.isEmpty) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }

      final allCompleted = dayTasks.every((task) => task.isCompleted);
      if (!allCompleted) {
        if (DateTimeUtils.isSameDay(day, now)) {
          day = day.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }

      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static int _longestStreak(List<Task> tasks) {
    final days = _daysWithTasks(tasks);
    if (days.isEmpty) return 0;

    var longest = 0;
    var current = 0;
    DateTime? previousDay;

    for (final day in days) {
      final dayTasks = _tasksForDay(tasks, day);
      final success = dayTasks.every((task) => task.isCompleted);
      if (!success) {
        current = 0;
        previousDay = day;
        continue;
      }

      if (previousDay != null &&
          day.difference(previousDay).inDays == 1 &&
          current > 0) {
        current++;
      } else {
        current = 1;
      }

      if (current > longest) longest = current;
      previousDay = day;
    }

    return longest;
  }

  static List<Task> _tasksForDay(List<Task> tasks, DateTime day) {
    return tasks
        .where((task) => DateTimeUtils.isSameDay(task.startTime, day))
        .toList(growable: false);
  }

  static List<DateTime> _daysWithTasks(List<Task> tasks) {
    final days = tasks.map((task) => DateTimeUtils.dateOnly(task.startTime)).toSet();
    final sorted = days.toList()..sort();
    return sorted;
  }

  static DateTime? _earliestTaskDay(List<Task> tasks) {
    if (tasks.isEmpty) return null;
    var earliest = DateTimeUtils.dateOnly(tasks.first.startTime);
    for (final task in tasks.skip(1)) {
      final day = DateTimeUtils.dateOnly(task.startTime);
      if (day.isBefore(earliest)) earliest = day;
    }
    return earliest;
  }
}
