import 'package:discipline/core/constants/default_blocked_apps.dart';
import 'package:discipline/features/settings/domain/entities/app_settings.dart';
import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
  const SettingsModel({
    required this.defaultReminderIntervalMinutes,
    required this.accessibilityEnforcementEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.darkThemeEnabled,
    required this.blockedPackageNames,
  });

  final int defaultReminderIntervalMinutes;
  final bool accessibilityEnforcementEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool darkThemeEnabled;
  final List<String> blockedPackageNames;

  AppSettings toEntity() {
    return AppSettings(
      defaultReminderInterval:
          Duration(minutes: defaultReminderIntervalMinutes),
      accessibilityEnforcementEnabled: accessibilityEnforcementEnabled,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      darkThemeEnabled: darkThemeEnabled,
      blockedPackageNames: List.unmodifiable(blockedPackageNames),
    );
  }

  factory SettingsModel.fromEntity(AppSettings settings) {
    return SettingsModel(
      defaultReminderIntervalMinutes:
          settings.defaultReminderInterval.inMinutes,
      accessibilityEnforcementEnabled:
          settings.accessibilityEnforcementEnabled,
      soundEnabled: settings.soundEnabled,
      vibrationEnabled: settings.vibrationEnabled,
      darkThemeEnabled: settings.darkThemeEnabled,
      blockedPackageNames: List<String>.from(settings.blockedPackageNames),
    );
  }

  factory SettingsModel.defaults() {
    return const SettingsModel(
      defaultReminderIntervalMinutes: 5,
      accessibilityEnforcementEnabled: false,
      soundEnabled: true,
      vibrationEnabled: true,
      darkThemeEnabled: true,
      blockedPackageNames: DefaultBlockedApps.packages,
    );
  }

  SettingsModel copyWith({
    int? defaultReminderIntervalMinutes,
    bool? accessibilityEnforcementEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? darkThemeEnabled,
    List<String>? blockedPackageNames,
  }) {
    return SettingsModel(
      defaultReminderIntervalMinutes: defaultReminderIntervalMinutes ??
          this.defaultReminderIntervalMinutes,
      accessibilityEnforcementEnabled: accessibilityEnforcementEnabled ??
          this.accessibilityEnforcementEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkThemeEnabled: darkThemeEnabled ?? this.darkThemeEnabled,
      blockedPackageNames: blockedPackageNames ?? this.blockedPackageNames,
    );
  }

  @override
  List<Object?> get props => [
        defaultReminderIntervalMinutes,
        accessibilityEnforcementEnabled,
        soundEnabled,
        vibrationEnabled,
        darkThemeEnabled,
        blockedPackageNames,
      ];
}
