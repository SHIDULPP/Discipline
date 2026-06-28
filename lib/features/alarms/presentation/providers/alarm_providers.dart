import 'package:discipline/features/alarms/data/datasources/alarm_platform_datasource.dart';
import 'package:discipline/features/alarms/data/datasources/alarm_platform_datasource_impl.dart';
import 'package:discipline/features/alarms/data/repositories/alarm_repository_impl.dart';
import 'package:discipline/features/alarms/domain/repositories/alarm_repository.dart';
import 'package:discipline/features/alarms/domain/usecases/cancel_alarm.dart';
import 'package:discipline/features/alarms/domain/usecases/schedule_alarm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final alarmPlatformDataSourceProvider = Provider<AlarmPlatformDataSource>((ref) {
  throw UnimplementedError(
    'AlarmPlatformDataSource must be overridden at startup',
  );
});

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepositoryImpl(ref.watch(alarmPlatformDataSourceProvider));
});

final scheduleAlarmProvider = Provider<ScheduleAlarm>((ref) {
  return ScheduleAlarm(ref.watch(alarmRepositoryProvider));
});

final cancelAlarmProvider = Provider<CancelAlarm>((ref) {
  return CancelAlarm(ref.watch(alarmRepositoryProvider));
});

AlarmPlatformDataSource createAlarmPlatformDataSource() {
  return AlarmPlatformDataSourceImpl();
}
