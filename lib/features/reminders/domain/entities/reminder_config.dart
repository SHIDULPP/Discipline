import 'package:equatable/equatable.dart';

class ReminderConfig extends Equatable {
  const ReminderConfig({
    required this.taskId,
    required this.interval,
    required this.isActive,
    required this.lastTriggeredAt,
  });

  final String taskId;
  final Duration interval;
  final bool isActive;
  final DateTime? lastTriggeredAt;

  @override
  List<Object?> get props => [taskId, interval, isActive, lastTriggeredAt];
}
