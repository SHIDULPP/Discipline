import 'package:discipline/core/platform/discipline_platform_channel.dart';
import 'package:discipline/features/alarms/data/datasources/alarm_platform_datasource.dart';

class AlarmPlatformDataSourceImpl implements AlarmPlatformDataSource {
  AlarmPlatformDataSourceImpl([DisciplinePlatformChannel? channel])
      : _channel = channel ?? DisciplinePlatformChannel();

  final DisciplinePlatformChannel _channel;

  @override
  Future<void> scheduleExactAlarm({
    required String taskId,
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
    required DateTime triggerAt,
    required Duration repeatInterval,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) {
    return _channel.scheduleExactAlarm(
      taskId: taskId,
      heading: heading,
      subHeading: subHeading,
      startTime: startTime,
      completionDuration: completionDuration,
      triggerAt: triggerAt,
      repeatInterval: repeatInterval,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );
  }

  @override
  Future<void> cancelExactAlarm({required String taskId}) {
    return _channel.cancelExactAlarm(taskId);
  }

  @override
  Future<void> cancelAllAlarms() => _channel.cancelAllAlarms();

  @override
  Future<void> rescheduleAllAlarms() => _channel.rescheduleAllAlarms();

  @override
  Future<void> syncTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) {
    return _channel.syncTaskCompletion(
      taskId: taskId,
      isCompleted: isCompleted,
    );
  }

  @override
  Future<List<String>> consumePendingCompletions() {
    return _channel.consumePendingCompletions();
  }

  @override
  Future<bool> canScheduleExactAlarms() {
    return _channel.canScheduleExactAlarms();
  }

  @override
  Future<void> openExactAlarmSettings() {
    return _channel.openExactAlarmSettings();
  }
}
