import 'package:discipline/features/statistics/domain/entities/period_progress_point.dart';
import 'package:equatable/equatable.dart';

class TaskStatistics extends Equatable {
  const TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyProgress,
    required this.monthlyProgress,
  });

  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final double completionRate;
  final int currentStreak;
  final int longestStreak;
  final List<PeriodProgressPoint> weeklyProgress;
  final List<PeriodProgressPoint> monthlyProgress;

  @override
  List<Object?> get props => [
        totalTasks,
        completedTasks,
        overdueTasks,
        completionRate,
        currentStreak,
        longestStreak,
        weeklyProgress,
        monthlyProgress,
      ];
}
