import 'package:discipline/core/platform/discipline_platform_channel.dart';
import 'package:discipline/features/settings/domain/entities/device_permissions_status.dart';
import 'package:discipline/features/settings/domain/repositories/device_permissions_repository.dart';

class DevicePermissionsRepositoryImpl implements DevicePermissionsRepository {
  DevicePermissionsRepositoryImpl(this._channel);

  final DisciplinePlatformChannel _channel;

  @override
  Future<DevicePermissionsStatus> getStatus() async {
    final results = await Future.wait([
      _channel.isAccessibilityServiceEnabled(),
      _channel.canScheduleExactAlarms(),
      _channel.isIgnoringBatteryOptimizations(),
    ]);

    return DevicePermissionsStatus(
      accessibilityEnabled: results[0],
      exactAlarmsGranted: results[1],
      batteryOptimizationDisabled: results[2],
    );
  }

  @override
  Future<void> openAccessibilitySettings() =>
      _channel.openAccessibilitySettings();

  @override
  Future<void> openExactAlarmSettings() => _channel.openExactAlarmSettings();

  @override
  Future<void> openBatteryOptimizationSettings() =>
      _channel.openBatteryOptimizationSettings();
}
