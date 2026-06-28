import 'package:discipline/core/constants/app_constants.dart';
import 'package:discipline/core/data/hive_error_mapper.dart';
import 'package:discipline/core/errors/exceptions.dart';
import 'package:discipline/core/services/hive_service.dart';
import 'package:discipline/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:discipline/features/settings/data/models/settings_model.dart';

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl(this._hiveService);

  final HiveService _hiveService;

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final stored =
          _hiveService.settingsBox.get(AppConstants.settingsRecordKey);
      if (stored != null) {
        return stored;
      }

      final defaults = SettingsModel.defaults();
      await _hiveService.settingsBox.put(
        AppConstants.settingsRecordKey,
        defaults,
      );
      return defaults;
    } catch (error) {
      HiveErrorMapper.rethrowAsCacheException(error, 'Failed to read settings');
    }
  }

  @override
  Future<SettingsModel> saveSettings(SettingsModel settings) async {
    try {
      await _hiveService.settingsBox.put(
        AppConstants.settingsRecordKey,
        settings,
      );
      final saved =
          _hiveService.settingsBox.get(AppConstants.settingsRecordKey);
      if (saved == null) {
        throw const CacheException('Failed to persist settings');
      }
      return saved;
    } catch (error) {
      HiveErrorMapper.rethrowAsCacheException(error, 'Failed to save settings');
    }
  }

  @override
  Stream<SettingsModel> watchSettings() async* {
    yield await getSettings();
    await for (final _ in _hiveService.settingsBox.watch(
      key: AppConstants.settingsRecordKey,
    )) {
      yield await getSettings();
    }
  }
}
