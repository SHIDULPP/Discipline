import 'package:discipline/features/alarms/data/datasources/alarm_platform_datasource.dart';
import 'package:discipline/features/alarms/domain/entities/alarm_schedule.dart';
import 'package:discipline/features/alarms/domain/repositories/alarm_repository.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  AlarmRepositoryImpl(this._platformDataSource);

  final AlarmPlatformDataSource _platformDataSource;

  @override
  Future<void> cancelAlarm(String taskId) async {
    await _platformDataSource.syncTaskCompletion(
      taskId: taskId,
      isCompleted: true,
    );
  }

  @override
  Future<void> cancelAllAlarms() => _platformDataSource.cancelAllAlarms();

  @override
  Future<List<AlarmSchedule>> getScheduledAlarms() async => [];

  @override
  Future<void> scheduleAlarm(AlarmSchedule schedule) async {
    if (!schedule.isActive) {
      await cancelAlarm(schedule.taskId);
      return;
    }

    await _platformDataSource.scheduleExactAlarm(
      taskId: schedule.taskId,
      heading: schedule.heading,
      subHeading: schedule.subHeading,
      startTime: schedule.startTime,
      completionDuration: schedule.completionDuration,
      triggerAt: schedule.triggerAt,
      repeatInterval: schedule.repeatInterval,
      soundEnabled: schedule.soundEnabled,
      vibrationEnabled: schedule.vibrationEnabled,
    );
  }
}
