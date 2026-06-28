import 'package:discipline/features/reminders/data/adapters/reminder_config_model_adapter.dart';
import 'package:discipline/features/reminders/data/models/reminder_config_model.dart';
import 'package:discipline/features/settings/data/adapters/settings_model_adapter.dart';
import 'package:discipline/features/settings/data/models/settings_model.dart';
import 'package:discipline/features/tasks/data/adapters/task_adapters.dart';
import 'package:discipline/features/tasks/data/models/task_model.dart';
import 'package:discipline/features/tasks/domain/entities/task_state.dart';
import 'package:hive/hive.dart';

abstract final class HiveAdapterRegistry {
  static void registerAll() {
    _register<TaskModel>(TaskModelAdapter());
    _register<SettingsModel>(SettingsModelAdapter());
    _register<ReminderConfigModel>(ReminderConfigModelAdapter());
    _register<TaskState>(TaskStateAdapter());
  }

  static void _register<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }
}
