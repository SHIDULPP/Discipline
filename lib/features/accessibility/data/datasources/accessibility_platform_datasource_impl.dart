import 'package:discipline/core/platform/discipline_platform_channel.dart';
import 'package:discipline/features/accessibility/data/datasources/accessibility_platform_datasource.dart';

class AccessibilityPlatformDataSourceImpl implements AccessibilityPlatformDataSource {
  AccessibilityPlatformDataSourceImpl([DisciplinePlatformChannel? channel])
      : _channel = channel ?? DisciplinePlatformChannel();

  final DisciplinePlatformChannel _channel;

  @override
  Future<bool> isAccessibilityServiceEnabled() {
    return _channel.isAccessibilityServiceEnabled();
  }

  @override
  Future<void> openAccessibilitySettings() {
    return _channel.openAccessibilitySettings();
  }

  @override
  Future<void> setEnforcementState({
    required bool enforcementEnabled,
    required bool isTaskRunning,
    String? activeTaskId,
  }) {
    return _channel.setEnforcementState(
      enforcementEnabled: enforcementEnabled,
      isTaskRunning: isTaskRunning,
      activeTaskId: activeTaskId,
    );
  }

  @override
  Future<void> setBlockedApps(List<String> packages) {
    return _channel.setBlockedApps(packages);
  }

  @override
  Future<List<String>> getBlockedApps() => _channel.getBlockedApps();

  @override
  Future<List<Map<String, String>>> getInstalledDistractionApps() {
    return _channel.getInstalledDistractionApps();
  }
}
