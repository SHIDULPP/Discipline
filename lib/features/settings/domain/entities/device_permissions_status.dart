import 'package:equatable/equatable.dart';

class DevicePermissionsStatus extends Equatable {
  const DevicePermissionsStatus({
    required this.accessibilityEnabled,
    required this.exactAlarmsGranted,
    required this.batteryOptimizationDisabled,
  });

  final bool accessibilityEnabled;
  final bool exactAlarmsGranted;
  final bool batteryOptimizationDisabled;

  @override
  List<Object?> get props => [
        accessibilityEnabled,
        exactAlarmsGranted,
        batteryOptimizationDisabled,
      ];
}
