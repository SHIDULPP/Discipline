import 'package:discipline/features/settings/domain/entities/app_settings.dart';
import 'package:discipline/features/settings/domain/repositories/settings_repository.dart';

class UpdateSettings {
  const UpdateSettings(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> call(AppSettings settings) =>
      _repository.updateSettings(settings);
}
