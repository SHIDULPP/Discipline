import 'package:discipline/core/constants/app_constants.dart';
import 'package:discipline/core/data/hive_adapter_registry.dart';
import 'package:discipline/features/reminders/data/models/reminder_config_model.dart';
import 'package:discipline/features/settings/data/models/settings_model.dart';
import 'package:discipline/features/tasks/data/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('HiveService must be overridden at startup');
});

class HiveService {
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    HiveAdapterRegistry.registerAll();
    await openBoxes();
    _isInitialized = true;
  }

  Future<void> openBoxes() async {
    if (!Hive.isBoxOpen(AppConstants.hiveBoxTasks)) {
      await Hive.openBox<TaskModel>(AppConstants.hiveBoxTasks);
    }
    if (!Hive.isBoxOpen(AppConstants.hiveBoxSettings)) {
      await Hive.openBox<SettingsModel>(AppConstants.hiveBoxSettings);
    }
    if (!Hive.isBoxOpen(AppConstants.hiveBoxReminders)) {
      await Hive.openBox<ReminderConfigModel>(AppConstants.hiveBoxReminders);
    }
  }

  Box<TaskModel> get tasksBox => Hive.box<TaskModel>(AppConstants.hiveBoxTasks);

  Box<SettingsModel> get settingsBox =>
      Hive.box<SettingsModel>(AppConstants.hiveBoxSettings);

  Box<ReminderConfigModel> get remindersBox =>
      Hive.box<ReminderConfigModel>(AppConstants.hiveBoxReminders);
}
