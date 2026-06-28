import 'package:discipline/features/tasks/domain/entities/task_state.dart';
import 'package:equatable/equatable.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.heading,
    required this.subHeading,
    required this.startTime,
    required this.completionDuration,
    required this.isCompleted,
    required this.state,
  });

  final String id;
  final String heading;
  final String subHeading;
  final DateTime startTime;
  final Duration completionDuration;
  final bool isCompleted;
  final TaskState state;

  @override
  List<Object?> get props => [
        id,
        heading,
        subHeading,
        startTime,
        completionDuration,
        isCompleted,
        state,
      ];
}
