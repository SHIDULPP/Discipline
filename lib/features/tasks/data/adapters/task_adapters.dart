import 'package:discipline/core/constants/hive_constants.dart';
import 'package:discipline/features/tasks/data/models/task_model.dart';
import 'package:discipline/features/tasks/domain/entities/task_state.dart';
import 'package:hive/hive.dart';

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = HiveConstants.taskModelTypeId;

  @override
  TaskModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return TaskModel(
      id: fields[0] as String,
      heading: fields[1] as String,
      subHeading: fields[2] as String,
      startTimeMillis: fields[3] as int,
      completionDurationMinutes: fields[4] as int,
      isCompleted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.heading)
      ..writeByte(2)
      ..write(obj.subHeading)
      ..writeByte(3)
      ..write(obj.startTimeMillis)
      ..writeByte(4)
      ..write(obj.completionDurationMinutes)
      ..writeByte(5)
      ..write(obj.isCompleted);
  }
}

class TaskStateAdapter extends TypeAdapter<TaskState> {
  @override
  final int typeId = HiveConstants.taskStateTypeId;

  @override
  TaskState read(BinaryReader reader) {
    return TaskState.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TaskState obj) {
    writer.writeByte(obj.index);
  }
}
