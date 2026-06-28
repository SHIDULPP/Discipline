import 'package:discipline/features/accessibility/domain/entities/accessibility_status.dart';
import 'package:discipline/features/accessibility/domain/entities/blocked_app.dart';

abstract class AccessibilityRepository {
  Future<AccessibilityStatus> getStatus();

  Future<void> openAccessibilitySettings();

  Future<void> setEnforcementActive({required bool active, String? taskId});

  Future<void> syncEnforcementState({
    required bool enforcementEnabled,
    required bool isTaskRunning,
    String? activeTaskId,
  });

  Future<void> syncBlockedApps(List<String> packages);

  Future<List<BlockedApp>> getBlockedAppCandidates(List<String> blockedPackages);
}
