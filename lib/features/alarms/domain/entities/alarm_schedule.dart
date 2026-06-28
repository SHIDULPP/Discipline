import 'package:equatable/equatable.dart';

class AlarmSchedule extends Equatable {
  const AlarmSchedule({
    required this.taskId,
    required this.heading,
    required this.subHeading,
    required this.startTime,
    required this.completionDuration,
    required this.triggerAt,
    required this.repeatInterval,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.isActive,
  });

  final String taskId;
  final String heading;
  final String subHeading;
  final DateTime startTime;
  final Duration completionDuration;
  final DateTime triggerAt;
  final Duration repeatInterval;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool isActive;

  @override
  List<Object?> get props => [
        taskId,
        heading,
        subHeading,
        startTime,
        completionDuration,
        triggerAt,
        repeatInterval,
        soundEnabled,
        vibrationEnabled,
        isActive,
      ];
}
