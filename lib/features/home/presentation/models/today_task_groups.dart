import 'package:discipline/core/utils/date_time_utils.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/entities/task_state.dart';

class TodayTaskGroups {
  const TodayTaskGroups({
    required this.upcoming,
    required this.running,
    required this.completed,
  });

  final List<Task> upcoming;
  final List<Task> running;
  final List<Task> completed;

  List<Task> get all => [...upcoming, ...running, ...completed];

  int get totalCount => all.length;

  int get completedCount => completed.length;

  int get runningCount => running.length;

  double get completionRate =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  static TodayTaskGroups fromTasks(List<Task> tasks, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = tasks
        .map((task) => _withFreshState(task, now: current))
        .where((task) => DateTimeUtils.isScheduledToday(task.startTime, current))
        .toList();

    final upcoming = <Task>[];
    final running = <Task>[];
    final completed = <Task>[];

    for (final task in today) {
      switch (task.state) {
        case TaskState.upcoming:
          upcoming.add(task);
        case TaskState.running:
        case TaskState.overdue:
          running.add(task);
        case TaskState.completed:
          completed.add(task);
      }
    }

    int compareByStart(Task a, Task b) =>
        a.startTime.compareTo(b.startTime);

    upcoming.sort(compareByStart);
    running.sort(compareByStart);
    completed.sort(compareByStart);

    return TodayTaskGroups(
      upcoming: upcoming,
      running: running,
      completed: completed,
    );
  }

  static Task _withFreshState(Task task, {required DateTime now}) {
    return Task(
      id: task.id,
      heading: task.heading,
      subHeading: task.subHeading,
      startTime: task.startTime,
      completionDuration: task.completionDuration,
      isCompleted: task.isCompleted,
      state: DateTimeUtils.resolveState(
        startTime: task.startTime,
        completionDuration: task.completionDuration,
        isCompleted: task.isCompleted,
        now: now,
      ),
    );
  }
}

class HomeStatistics {
  const HomeStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.runningTasks,
    required this.upcomingTasks,
    required this.completionRate,
  });

  final int totalTasks;
  final int completedTasks;
  final int runningTasks;
  final int upcomingTasks;
  final double completionRate;

  factory HomeStatistics.fromGroups(TodayTaskGroups groups) {
    return HomeStatistics(
      totalTasks: groups.totalCount,
      completedTasks: groups.completedCount,
      runningTasks: groups.runningCount,
      upcomingTasks: groups.upcoming.length,
      completionRate: groups.completionRate,
    );
  }
}
