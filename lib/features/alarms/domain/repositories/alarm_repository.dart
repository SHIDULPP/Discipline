import 'package:discipline/features/alarms/domain/entities/alarm_schedule.dart';

abstract class AlarmRepository {
  Future<void> scheduleAlarm(AlarmSchedule schedule);

  Future<void> cancelAlarm(String taskId);

  Future<void> cancelAllAlarms();

  Future<List<AlarmSchedule>> getScheduledAlarms();
}
