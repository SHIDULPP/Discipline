import 'package:flutter/services.dart';

class DisciplinePlatformChannel {
  DisciplinePlatformChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'com.discipline.app/platform';

  final MethodChannel _channel;

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
  }) async {
    await _channel.invokeMethod<void>('scheduleExactAlarm', {
      'taskId': taskId,
      'heading': heading,
      'subHeading': subHeading,
      'startTimeMillis': startTime.millisecondsSinceEpoch,
      'completionDurationMillis': completionDuration.inMilliseconds,
      'triggerAtMillis': triggerAt.millisecondsSinceEpoch,
      'repeatIntervalMillis': repeatInterval.inMilliseconds,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'isCompleted': false,
    });
  }

  Future<void> cancelExactAlarm(String taskId) async {
    await _channel.invokeMethod<void>('cancelExactAlarm', {'taskId': taskId});
  }

  Future<void> cancelAllAlarms() async {
    await _channel.invokeMethod<void>('cancelAllAlarms');
  }

  Future<void> rescheduleAllAlarms() async {
    await _channel.invokeMethod<void>('rescheduleAllAlarms');
  }

  Future<void> syncTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    await _channel.invokeMethod<void>('syncTaskCompletion', {
      'taskId': taskId,
      'isCompleted': isCompleted,
    });
  }

  Future<List<String>> consumePendingCompletions() async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getPendingCompletions',
    );
    return result?.cast<String>() ?? [];
  }

  Future<bool> canScheduleExactAlarms() async {
    final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
    return result ?? false;
  }

  Future<void> openExactAlarmSettings() async {
    await _channel.invokeMethod<void>('openExactAlarmSettings');
  }

  Future<bool> isAccessibilityServiceEnabled() async {
    final result = await _channel.invokeMethod<bool>('isAccessibilityEnabled');
    return result ?? false;
  }

  Future<void> openAccessibilitySettings() async {
    await _channel.invokeMethod<void>('openAccessibilitySettings');
  }

  Future<void> setEnforcementState({
    required bool enforcementEnabled,
    required bool isTaskRunning,
    String? activeTaskId,
  }) async {
    await _channel.invokeMethod<void>('setEnforcementState', {
      'enforcementEnabled': enforcementEnabled,
      'isTaskRunning': isTaskRunning,
      'activeTaskId': activeTaskId,
    });
  }

  Future<void> setBlockedApps(List<String> packages) async {
    await _channel.invokeMethod<void>('setBlockedApps', {
      'packages': packages,
    });
  }

  Future<List<String>> getBlockedApps() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getBlockedApps');
    return result?.cast<String>() ?? [];
  }

  Future<List<Map<String, String>>> getInstalledDistractionApps() async {
    final result =
        await _channel.invokeMethod<List<dynamic>>('getInstalledDistractionApps');
    if (result == null) return [];
    return result.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return {
        'packageName': map['packageName'] as String,
        'label': map['label'] as String,
      };
    }).toList();
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    final result =
        await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
    return result ?? false;
  }

  Future<void> openBatteryOptimizationSettings() async {
    await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
  }
}
