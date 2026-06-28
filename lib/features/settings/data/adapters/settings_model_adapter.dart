import 'package:discipline/core/constants/default_blocked_apps.dart';
import 'package:discipline/core/constants/hive_constants.dart';
import 'package:discipline/features/settings/data/models/settings_model.dart';
import 'package:hive/hive.dart';

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = HiveConstants.settingsModelTypeId;

  @override
  SettingsModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return SettingsModel(
      defaultReminderIntervalMinutes: fields[0] as int,
      accessibilityEnforcementEnabled: fields[1] as bool,
      soundEnabled: fields[2] as bool,
      vibrationEnabled: fields[3] as bool,
      blockedPackageNames: fields.containsKey(4)
          ? (fields[4] as List).cast<String>()
          : List<String>.from(DefaultBlockedApps.packages),
      darkThemeEnabled: fields.containsKey(5) ? fields[5] as bool : true,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.defaultReminderIntervalMinutes)
      ..writeByte(1)
      ..write(obj.accessibilityEnforcementEnabled)
      ..writeByte(2)
      ..write(obj.soundEnabled)
      ..writeByte(3)
      ..write(obj.vibrationEnabled)
      ..writeByte(4)
      ..write(obj.blockedPackageNames)
      ..writeByte(5)
      ..write(obj.darkThemeEnabled);
  }
}
