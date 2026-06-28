import 'package:discipline/features/alarms/domain/entities/alarm_schedule.dart';
import 'package:discipline/features/alarms/domain/repositories/alarm_repository.dart';

class ScheduleAlarm {
  const ScheduleAlarm(this._repository);

  final AlarmRepository _repository;

  Future<void> call(AlarmSchedule schedule) =>
      _repository.scheduleAlarm(schedule);
}
