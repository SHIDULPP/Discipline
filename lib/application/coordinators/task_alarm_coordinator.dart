import 'package:discipline/features/alarms/data/datasources/alarm_platform_datasource.dart';
import 'package:discipline/features/alarms/domain/entities/alarm_schedule.dart';
import 'package:discipline/features/alarms/domain/usecases/cancel_alarm.dart';
import 'package:discipline/features/alarms/domain/usecases/schedule_alarm.dart';
import 'package:discipline/features/settings/domain/entities/app_settings.dart';
import 'package:discipline/features/settings/domain/usecases/get_settings.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/usecases/get_tasks.dart';
import 'package:discipline/features/tasks/domain/usecases/mark_task_completed.dart';
import 'package:permission_handler/permission_handler.dart';

/// Application-layer orchestrator for native exact alarms.
///
/// Lives outside `domain/` because it coordinates multiple bounded contexts
/// (tasks, settings, alarms) and platform permissions.
class TaskAlarmCoordinator {
  TaskAlarmCoordinator({
    required AlarmPlatformDataSource alarmPlatform,
    required ScheduleAlarm scheduleAlarm,
    required CancelAlarm cancelAlarm,
    required GetTasks getTasks,
    required GetSettings getSettings,
    required MarkTaskCompleted markTaskCompleted,
  })  : _alarmPlatform = alarmPlatform,
        _scheduleAlarm = scheduleAlarm,
        _cancelAlarm = cancelAlarm,
        _getTasks = getTasks,
        _getSettings = getSettings,
        _markTaskCompleted = markTaskCompleted;

  final AlarmPlatformDataSource _alarmPlatform;
  final ScheduleAlarm _scheduleAlarm;
  final CancelAlarm _cancelAlarm;
  final GetTasks _getTasks;
  final GetSettings _getSettings;
  final MarkTaskCompleted _markTaskCompleted;

  Future<void> initialize() async {
    await Permission.notification.request();
    final canSchedule = await _alarmPlatform.canScheduleExactAlarms();
    if (!canSchedule) {
      await _alarmPlatform.openExactAlarmSettings();
    }
    await processPendingCompletions();
    await rescheduleAll();
  }

  Future<void> processPendingCompletions() async {
    final pending = await _alarmPlatform.consumePendingCompletions();
    for (final taskId in pending) {
      try {
        await _markTaskCompleted(taskId);
      } catch (_) {
        // Task may have been deleted after the alarm fired.
      }
      await cancelForTask(taskId);
    }
  }

  Future<void> rescheduleAll() async {
    final tasks = await _getTasks();
    final settings = await _getSettings();
    for (final task in tasks) {
      await syncTask(task, settings);
    }
  }

  Future<void> syncTask(Task task, AppSettings settings) async {
    if (task.isCompleted) {
      await cancelForTask(task.id);
      return;
    }

    final schedule = AlarmSchedule(
      taskId: task.id,
      heading: task.heading,
      subHeading: task.subHeading,
      startTime: task.startTime,
      completionDuration: task.completionDuration,
      triggerAt: _resolveTriggerAt(task.startTime),
      repeatInterval: settings.defaultReminderInterval,
      soundEnabled: settings.soundEnabled,
      vibrationEnabled: settings.vibrationEnabled,
      isActive: true,
    );

    await _scheduleAlarm(schedule);
  }

  Future<void> cancelForTask(String taskId) => _cancelAlarm(taskId);

  Future<void> onTaskDeleted(String taskId) => cancelForTask(taskId);

  DateTime _resolveTriggerAt(DateTime startTime) {
    final now = DateTime.now();
    if (startTime.isAfter(now)) return startTime;
    return now.add(const Duration(seconds: 3));
  }
}
