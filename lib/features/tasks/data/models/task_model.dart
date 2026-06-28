import 'package:discipline/core/utils/date_time_utils.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.heading,
    required this.subHeading,
    required this.startTimeMillis,
    required this.completionDurationMinutes,
    required this.isCompleted,
  });

  final String id;
  final String heading;
  final String subHeading;
  final int startTimeMillis;
  final int completionDurationMinutes;
  final bool isCompleted;

  DateTime get startTime =>
      DateTime.fromMillisecondsSinceEpoch(startTimeMillis);

  Duration get completionDuration =>
      Duration(minutes: completionDurationMinutes);

  Task toEntity() {
    return Task(
      id: id,
      heading: heading,
      subHeading: subHeading,
      startTime: startTime,
      completionDuration: completionDuration,
      isCompleted: isCompleted,
      state: DateTimeUtils.resolveState(
        startTime: startTime,
        completionDuration: completionDuration,
        isCompleted: isCompleted,
      ),
    );
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      heading: task.heading,
      subHeading: task.subHeading,
      startTimeMillis: task.startTime.millisecondsSinceEpoch,
      completionDurationMinutes: task.completionDuration.inMinutes,
      isCompleted: task.isCompleted,
    );
  }

  TaskModel copyWith({
    String? id,
    String? heading,
    String? subHeading,
    int? startTimeMillis,
    int? completionDurationMinutes,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      heading: heading ?? this.heading,
      subHeading: subHeading ?? this.subHeading,
      startTimeMillis: startTimeMillis ?? this.startTimeMillis,
      completionDurationMinutes:
          completionDurationMinutes ?? this.completionDurationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        heading,
        subHeading,
        startTimeMillis,
        completionDurationMinutes,
        isCompleted,
      ];
}
