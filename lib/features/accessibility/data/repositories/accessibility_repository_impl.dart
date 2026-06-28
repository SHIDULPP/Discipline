import 'package:discipline/features/accessibility/data/datasources/accessibility_platform_datasource.dart';
import 'package:discipline/features/accessibility/domain/entities/accessibility_status.dart';
import 'package:discipline/features/accessibility/domain/entities/blocked_app.dart';
import 'package:discipline/features/accessibility/domain/repositories/accessibility_repository.dart';

class AccessibilityRepositoryImpl implements AccessibilityRepository {
  AccessibilityRepositoryImpl(this._platformDataSource);

  final AccessibilityPlatformDataSource _platformDataSource;

  @override
  Future<AccessibilityStatus> getStatus() async {
    final isEnabled = await _platformDataSource.isAccessibilityServiceEnabled();
    return AccessibilityStatus(
      isEnabled: isEnabled,
      isServiceConnected: isEnabled,
    );
  }

  @override
  Future<void> openAccessibilitySettings() {
    return _platformDataSource.openAccessibilitySettings();
  }

  @override
  Future<void> setEnforcementActive({
    required bool active,
    String? taskId,
  }) {
    return _platformDataSource.setEnforcementState(
      enforcementEnabled: active,
      isTaskRunning: taskId != null,
      activeTaskId: taskId,
    );
  }

  @override
  Future<void> syncEnforcementState({
    required bool enforcementEnabled,
    required bool isTaskRunning,
    String? activeTaskId,
  }) {
    return _platformDataSource.setEnforcementState(
      enforcementEnabled: enforcementEnabled,
      isTaskRunning: isTaskRunning,
      activeTaskId: activeTaskId,
    );
  }

  @override
  Future<void> syncBlockedApps(List<String> packages) {
    return _platformDataSource.setBlockedApps(packages);
  }

  @override
  Future<List<BlockedApp>> getBlockedAppCandidates(
    List<String> blockedPackages,
  ) async {
    final installed = await _platformDataSource.getInstalledDistractionApps();
    final installedPackages = installed.map((e) => e['packageName']!).toSet();

    final candidates = <BlockedApp>[
      for (final app in installed)
        BlockedApp(
          packageName: app['packageName']!,
          label: app['label']!,
          isBlocked: blockedPackages.contains(app['packageName']),
          isInstalled: true,
        ),
    ];

    for (final package in blockedPackages) {
      if (!installedPackages.contains(package)) {
        candidates.add(
          BlockedApp(
            packageName: package,
            label: package,
            isBlocked: true,
            isInstalled: false,
          ),
        );
      }
    }

    candidates.sort((a, b) => a.label.compareTo(b.label));
    return candidates;
  }
}
