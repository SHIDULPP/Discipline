import 'package:equatable/equatable.dart';

class PeriodProgressPoint extends Equatable {
  const PeriodProgressPoint({
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
  });

  final DateTime date;
  final int totalTasks;
  final int completedTasks;

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  bool get hasTasks => totalTasks > 0;

  @override
  List<Object?> get props => [date, totalTasks, completedTasks];
}
