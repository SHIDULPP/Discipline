import 'package:discipline/core/platform/discipline_platform_channel.dart';
import 'package:discipline/features/accessibility/data/datasources/accessibility_platform_datasource.dart';
import 'package:discipline/features/accessibility/data/datasources/accessibility_platform_datasource_impl.dart';
import 'package:discipline/features/accessibility/data/repositories/accessibility_repository_impl.dart';
import 'package:discipline/features/accessibility/domain/repositories/accessibility_repository.dart';
import 'package:discipline/features/accessibility/domain/usecases/get_accessibility_status.dart';
import 'package:discipline/features/accessibility/domain/usecases/open_accessibility_settings.dart';
import 'package:discipline/features/accessibility/domain/usecases/set_enforcement_active.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accessibilityPlatformDataSourceProvider =
    Provider<AccessibilityPlatformDataSource>((ref) {
  throw UnimplementedError(
    'AccessibilityPlatformDataSource must be overridden at startup',
  );
});

final accessibilityRepositoryProvider = Provider<AccessibilityRepository>((ref) {
  return AccessibilityRepositoryImpl(
    ref.watch(accessibilityPlatformDataSourceProvider),
  );
});

final getAccessibilityStatusProvider = Provider<GetAccessibilityStatus>((ref) {
  return GetAccessibilityStatus(ref.watch(accessibilityRepositoryProvider));
});

final openAccessibilitySettingsProvider =
    Provider<OpenAccessibilitySettings>((ref) {
  return OpenAccessibilitySettings(ref.watch(accessibilityRepositoryProvider));
});

final setEnforcementActiveProvider = Provider<SetEnforcementActive>((ref) {
  return SetEnforcementActive(ref.watch(accessibilityRepositoryProvider));
});

AccessibilityPlatformDataSource createAccessibilityPlatformDataSource([
  DisciplinePlatformChannel? channel,
]) {
  return AccessibilityPlatformDataSourceImpl(channel);
}
