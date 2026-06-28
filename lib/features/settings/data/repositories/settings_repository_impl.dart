import 'package:discipline/core/constants/app_constants.dart';
import 'package:discipline/core/errors/exceptions.dart';
import 'package:discipline/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:discipline/features/settings/data/models/settings_model.dart';
import 'package:discipline/features/settings/domain/entities/app_settings.dart';
import 'package:discipline/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<AppSettings> getSettings() async {
    final model = await _localDataSource.getSettings();
    return model.toEntity();
  }

  @override
  Future<AppSettings> updateSettings(AppSettings settings) async {
    _validate(settings);

    final model = SettingsModel.fromEntity(settings);
    final saved = await _localDataSource.saveSettings(model);
    return saved.toEntity();
  }

  void _validate(AppSettings settings) {
    final minutes = settings.defaultReminderInterval.inMinutes;
    if (minutes < 1) {
      throw const ValidationException(
        'Default reminder interval must be at least 1 minute',
      );
    }
    if (minutes > AppConstants.maxCompletionDurationMinutes) {
      throw const ValidationException(
        'Default reminder interval cannot exceed 24 hours',
      );
    }
  }
}
