import 'package:discipline/features/statistics/domain/services/statistics_calculator.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/entities/task_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatisticsCalculator', () {
    final now = DateTime(2026, 6, 28, 12);

    Task task({
      required String id,
      required DateTime start,
      bool completed = false,
    }) {
      return Task(
        id: id,
        heading: 'Task $id',
        subHeading: '',
        startTime: start,
        completionDuration: const Duration(hours: 1),
        isCompleted: completed,
        state: completed ? TaskState.completed : TaskState.running,
      );
    }

    test('computes completion rate', () {
      final stats = StatisticsCalculator.compute(
        [
          task(id: '1', start: now, completed: true),
          task(id: '2', start: now),
        ],
        now: now,
      );

      expect(stats.totalTasks, 2);
      expect(stats.completedTasks, 1);
      expect(stats.completionRate, 0.5);
    });

    test('counts current streak for perfect days', () {
      final stats = StatisticsCalculator.compute(
        [
          task(
            id: '1',
            start: DateTime(2026, 6, 27, 9),
            completed: true,
          ),
          task(
            id: '2',
            start: DateTime(2026, 6, 28, 9),
            completed: true,
          ),
        ],
        now: now,
      );

      expect(stats.currentStreak, 2);
      expect(stats.longestStreak, 2);
    });
  });
}
