import 'package:discipline/features/settings/domain/entities/app_settings.dart';
import 'package:discipline/features/settings/domain/repositories/settings_repository.dart';

class GetSettings {
  const GetSettings(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> call() => _repository.getSettings();
}
