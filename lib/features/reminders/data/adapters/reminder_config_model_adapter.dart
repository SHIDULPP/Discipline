import 'package:discipline/core/constants/hive_constants.dart';
import 'package:discipline/features/reminders/data/models/reminder_config_model.dart';
import 'package:hive/hive.dart';

class ReminderConfigModelAdapter extends TypeAdapter<ReminderConfigModel> {
  @override
  final int typeId = HiveConstants.reminderConfigTypeId;

  @override
  ReminderConfigModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return ReminderConfigModel(
      taskId: fields[0] as String,
      intervalMinutes: fields[1] as int,
      isActive: fields[2] as bool,
      lastTriggeredAtMillis: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderConfigModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.taskId)
      ..writeByte(1)
      ..write(obj.intervalMinutes)
      ..writeByte(2)
      ..write(obj.isActive)
      ..writeByte(3)
      ..write(obj.lastTriggeredAtMillis);
  }
}
