import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({
    required this.defaultReminderInterval,
    required this.accessibilityEnforcementEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.darkThemeEnabled,
    required this.blockedPackageNames,
  });

  final Duration defaultReminderInterval;
  final bool accessibilityEnforcementEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool darkThemeEnabled;
  final List<String> blockedPackageNames;

  AppSettings copyWith({
    Duration? defaultReminderInterval,
    bool? accessibilityEnforcementEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? darkThemeEnabled,
    List<String>? blockedPackageNames,
  }) {
    return AppSettings(
      defaultReminderInterval:
          defaultReminderInterval ?? this.defaultReminderInterval,
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
        defaultReminderInterval,
        accessibilityEnforcementEnabled,
        soundEnabled,
        vibrationEnabled,
        darkThemeEnabled,
        blockedPackageNames,
      ];
}
