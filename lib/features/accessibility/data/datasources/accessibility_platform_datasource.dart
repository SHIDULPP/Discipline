abstract class AccessibilityPlatformDataSource {
  Future<bool> isAccessibilityServiceEnabled();

  Future<void> openAccessibilitySettings();

  Future<void> setEnforcementState({
    required bool enforcementEnabled,
    required bool isTaskRunning,
    String? activeTaskId,
  });

  Future<void> setBlockedApps(List<String> packages);

  Future<List<String>> getBlockedApps();

  Future<List<Map<String, String>>> getInstalledDistractionApps();
}
