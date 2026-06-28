abstract final class AppConstants {
  static const String appName = 'Discipline';
  static const String hiveBoxTasks = 'tasks';
  static const String hiveBoxSettings = 'settings';
  static const String hiveBoxReminders = 'reminders';
  static const String settingsRecordKey = 'app_settings';
  static const Duration defaultReminderInterval = Duration(minutes: 5);
  static const int maxHeadingLength = 120;
  static const int maxSubHeadingLength = 240;
  static const int minCompletionDurationMinutes = 1;
  static const int maxCompletionDurationMinutes = 24 * 60;
}
