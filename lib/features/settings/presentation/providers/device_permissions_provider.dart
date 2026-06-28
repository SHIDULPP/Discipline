import 'package:discipline/core/platform/discipline_platform_channel.dart';
import 'package:discipline/features/settings/data/repositories/device_permissions_repository_impl.dart';
import 'package:discipline/features/settings/domain/entities/device_permissions_status.dart';
import 'package:discipline/features/settings/domain/repositories/device_permissions_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final disciplinePlatformChannelProvider = Provider<DisciplinePlatformChannel>(
  (ref) => DisciplinePlatformChannel(),
);

final devicePermissionsRepositoryProvider =
    Provider<DevicePermissionsRepository>((ref) {
  return DevicePermissionsRepositoryImpl(
    ref.watch(disciplinePlatformChannelProvider),
  );
});

final devicePermissionsStatusProvider =
    FutureProvider.autoDispose<DevicePermissionsStatus>((ref) {
  return ref.watch(devicePermissionsRepositoryProvider).getStatus();
});
