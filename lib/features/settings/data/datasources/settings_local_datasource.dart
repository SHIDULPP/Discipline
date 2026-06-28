import 'package:discipline/features/settings/data/models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();

  Future<SettingsModel> saveSettings(SettingsModel settings);

  Stream<SettingsModel> watchSettings();
}
