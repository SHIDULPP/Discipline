import 'package:discipline/features/reminders/domain/entities/reminder_config.dart';
import 'package:equatable/equatable.dart';

class ReminderConfigModel extends Equatable {
  const ReminderConfigModel({
    required this.taskId,
    required this.intervalMinutes,
    required this.isActive,
    this.lastTriggeredAtMillis,
  });

  final String taskId;
  final int intervalMinutes;
  final bool isActive;
  final int? lastTriggeredAtMillis;

  ReminderConfig toEntity() {
    return ReminderConfig(
      taskId: taskId,
      interval: Duration(minutes: intervalMinutes),
      isActive: isActive,
      lastTriggeredAt: lastTriggeredAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(lastTriggeredAtMillis!)
          : null,
    );
  }

  factory ReminderConfigModel.fromEntity(ReminderConfig config) {
    return ReminderConfigModel(
      taskId: config.taskId,
      intervalMinutes: config.interval.inMinutes,
      isActive: config.isActive,
      lastTriggeredAtMillis: config.lastTriggeredAt?.millisecondsSinceEpoch,
    );
  }

  @override
  List<Object?> get props => [
        taskId,
        intervalMinutes,
        isActive,
        lastTriggeredAtMillis,
      ];
}
