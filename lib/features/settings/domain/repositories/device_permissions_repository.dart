import 'package:discipline/features/settings/domain/entities/device_permissions_status.dart';

abstract class DevicePermissionsRepository {
  Future<DevicePermissionsStatus> getStatus();

  Future<void> openAccessibilitySettings();

  Future<void> openExactAlarmSettings();

  Future<void> openBatteryOptimizationSettings();
}
