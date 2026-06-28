import 'package:discipline/core/services/hive_service.dart';
import 'package:discipline/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:discipline/features/settings/data/datasources/settings_local_datasource_impl.dart';
import 'package:discipline/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:discipline/features/settings/domain/entities/app_settings.dart';
import 'package:discipline/features/settings/domain/repositories/settings_repository.dart';
import 'package:discipline/features/settings/domain/usecases/get_settings.dart';
import 'package:discipline/features/settings/domain/usecases/update_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Data layer ──────────────────────────────────────────────────────────────

final settingsLocalDataSourceProvider =
    Provider<SettingsLocalDataSource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SettingsLocalDataSourceImpl(hiveService);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider));
});

// ── Use cases ─────────────────────────────────────────────────────────────────

final getSettingsProvider = Provider<GetSettings>((ref) {
  return GetSettings(ref.watch(settingsRepositoryProvider));
});

final updateSettingsProvider = Provider<UpdateSettings>((ref) {
  return UpdateSettings(ref.watch(settingsRepositoryProvider));
});

// ── Reactive streams ──────────────────────────────────────────────────────────

final settingsStreamProvider = StreamProvider<AppSettings>((ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return dataSource.watchSettings().map((model) => model.toEntity());
});

// ── CRUD facade ─────────────────────────────────────────────────────────────────

final settingsCrudProvider = Provider<SettingsCrud>((ref) => SettingsCrud(ref));

class SettingsCrud {
  const SettingsCrud(this._ref);

  final Ref _ref;

  Future<AppSettings> get() => _ref.read(getSettingsProvider)();

  Future<AppSettings> update(AppSettings settings) =>
      _ref.read(updateSettingsProvider)(settings);
}
