abstract class AlarmPlatformDataSource {
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
  });

  Future<void> cancelExactAlarm({required String taskId});

  Future<void> cancelAllAlarms();

  Future<void> rescheduleAllAlarms();

  Future<void> syncTaskCompletion({
    required String taskId,
    required bool isCompleted,
  });

  Future<List<String>> consumePendingCompletions();

  Future<bool> canScheduleExactAlarms();

  Future<void> openExactAlarmSettings();
}
