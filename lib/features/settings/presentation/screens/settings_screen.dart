import 'package:discipline/application/providers/coordinator_providers.dart';
import 'package:discipline/core/constants/route_paths.dart';
import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/core/widgets/async_error_view.dart';
import 'package:discipline/features/settings/domain/entities/app_settings.dart';
import 'package:discipline/features/settings/domain/entities/device_permissions_status.dart';
import 'package:discipline/features/settings/presentation/providers/device_permissions_provider.dart';
import 'package:discipline/features/settings/presentation/providers/settings_providers.dart';
import 'package:discipline/features/settings/presentation/utils/settings_formatters.dart';
import 'package:discipline/features/settings/presentation/widgets/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(devicePermissionsStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsStreamProvider);
    final permissionsAsync = ref.watch(devicePermissionsStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AsyncErrorView(error: error),
        data: (settings) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(devicePermissionsStatusProvider);
              await ref.read(devicePermissionsStatusProvider.future);
            },
            color: AppColors.accent,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                const SettingsSectionHeader(title: 'REMINDERS'),
                _ReminderFrequencyCard(
                  currentMinutes: settings.defaultReminderInterval.inMinutes,
                  onChanged: (minutes) => _update(
                    settings,
                    settings.copyWith(
                      defaultReminderInterval: Duration(minutes: minutes),
                    ),
                  ),
                ),
                SettingsToggleTile(
                  icon: Icons.volume_up_rounded,
                  title: 'Alarm Sound',
                  subtitle: 'Play sound when task alarms fire',
                  value: settings.soundEnabled,
                  onChanged: (value) =>
                      _update(settings, settings.copyWith(soundEnabled: value)),
                ),
                const SettingsSectionHeader(title: 'APPEARANCE'),
                SettingsToggleTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Theme',
                  subtitle: 'Use Discipline dark interface',
                  value: settings.darkThemeEnabled,
                  onChanged: (value) => _update(
                    settings,
                    settings.copyWith(darkThemeEnabled: value),
                  ),
                ),
                const SettingsSectionHeader(title: 'DISTRACTION BLOCKING'),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.block_rounded, color: AppColors.accent),
                    title: const Text('Blocked Apps'),
                    subtitle: Text(
                      '${settings.blockedPackageNames.length} apps configured',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.upcoming,
                    ),
                    onTap: () => context.push(RoutePaths.accessibility),
                  ),
                ),
                const SettingsSectionHeader(title: 'PERMISSIONS'),
                permissionsAsync.when(
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, _) => Text('$error'),
                  data: (permissions) => _PermissionsSection(
                    permissions: permissions,
                    enforcementEnabled: settings.accessibilityEnforcementEnabled,
                    onOpenAccessibility: () => _openAccessibilitySettings(),
                    onOpenExactAlarms: () => _openExactAlarmSettings(),
                    onOpenBattery: () => _openBatterySettings(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _update(AppSettings previous, AppSettings updated) async {
    try {
      await ref.read(settingsCrudProvider).update(updated);

      final reminderChanged =
          previous.defaultReminderInterval != updated.defaultReminderInterval;
      final alarmPrefsChanged = previous.soundEnabled != updated.soundEnabled ||
          previous.vibrationEnabled != updated.vibrationEnabled;

      if (reminderChanged || alarmPrefsChanged) {
        await ref.read(taskAlarmCoordinatorProvider).rescheduleAll();
      }

      if (previous.blockedPackageNames != updated.blockedPackageNames) {
        await ref
            .read(accessibilityEnforcementCoordinatorProvider)
            .syncBlockedApps(updated.blockedPackageNames);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  Future<void> _openAccessibilitySettings() async {
    await ref.read(devicePermissionsRepositoryProvider).openAccessibilitySettings();
    ref.invalidate(devicePermissionsStatusProvider);
  }

  Future<void> _openExactAlarmSettings() async {
    await ref.read(devicePermissionsRepositoryProvider).openExactAlarmSettings();
    ref.invalidate(devicePermissionsStatusProvider);
  }

  Future<void> _openBatterySettings() async {
    await ref
        .read(devicePermissionsRepositoryProvider)
        .openBatteryOptimizationSettings();
    ref.invalidate(devicePermissionsStatusProvider);
  }
}

class _ReminderFrequencyCard extends StatelessWidget {
  const _ReminderFrequencyCard({
    required this.currentMinutes,
    required this.onChanged,
  });

  final int currentMinutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_outlined,
                    color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder Frequency',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Repeat every ${formatReminderInterval(Duration(minutes: currentMinutes))}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.upcoming,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SettingsUiConstants.reminderIntervalOptions.map((minutes) {
                final isSelected = minutes == currentMinutes;
                return ChoiceChip(
                  label: Text('${minutes}m'),
                  selected: isSelected,
                  onSelected: (_) => onChanged(minutes),
                  selectedColor: AppColors.accent.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.accent : AppColors.primary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.accent : AppColors.outline,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionsSection extends StatelessWidget {
  const _PermissionsSection({
    required this.permissions,
    required this.enforcementEnabled,
    required this.onOpenAccessibility,
    required this.onOpenExactAlarms,
    required this.onOpenBattery,
  });

  final DevicePermissionsStatus permissions;
  final bool enforcementEnabled;
  final VoidCallback onOpenAccessibility;
  final VoidCallback onOpenExactAlarms;
  final VoidCallback onOpenBattery;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsStatusTile(
          icon: Icons.accessibility_new_rounded,
          title: 'Accessibility Status',
          subtitle: permissions.accessibilityEnabled
              ? 'Service enabled${enforcementEnabled ? ' · enforcement on' : ''}'
              : 'Required to block distraction apps',
          isGranted: permissions.accessibilityEnabled,
          onTap: onOpenAccessibility,
        ),
        SettingsStatusTile(
          icon: Icons.alarm_rounded,
          title: 'Exact Alarm Permission',
          subtitle: permissions.exactAlarmsGranted
              ? 'Exact alarms allowed'
              : 'Required for on-time task alarms',
          isGranted: permissions.exactAlarmsGranted,
          onTap: permissions.exactAlarmsGranted ? null : onOpenExactAlarms,
        ),
        SettingsStatusTile(
          icon: Icons.battery_charging_full_rounded,
          title: 'Battery Optimization',
          subtitle: permissions.batteryOptimizationDisabled
              ? 'Unrestricted — alarms reliable'
              : 'Restricted — alarms may be delayed',
          isGranted: permissions.batteryOptimizationDisabled,
          onTap: permissions.batteryOptimizationDisabled ? null : onOpenBattery,
        ),
      ],
    );
  }
}
