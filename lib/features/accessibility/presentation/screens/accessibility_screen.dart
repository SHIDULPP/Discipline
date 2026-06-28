import 'package:discipline/application/providers/coordinator_providers.dart';
import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/core/widgets/async_error_view.dart';
import 'package:discipline/features/accessibility/domain/entities/blocked_app.dart';
import 'package:discipline/features/accessibility/presentation/providers/accessibility_providers.dart';
import 'package:discipline/features/settings/domain/entities/app_settings.dart';
import 'package:discipline/features/settings/presentation/providers/settings_providers.dart';
import 'package:discipline/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessibilityScreen extends ConsumerStatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  ConsumerState<AccessibilityScreen> createState() =>
      _AccessibilityScreenState();
}

class _AccessibilityScreenState extends ConsumerState<AccessibilityScreen>
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
      ref.invalidate(accessibilityStatusProvider);
    }
  }

  Future<void> _openAccessibilitySettings() async {
    await ref.read(openAccessibilitySettingsProvider).call();
    ref.invalidate(accessibilityStatusProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(accessibilityEnforcementSyncProvider);
    final statusAsync = ref.watch(accessibilityStatusProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final blockedAppsAsync = ref.watch(blockedAppsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
        actions: [
          IconButton(
            tooltip: 'Refresh status',
            onPressed: () => ref.invalidate(accessibilityStatusProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accessibilityStatusProvider);
          await ref.read(accessibilityStatusProvider.future);
        },
        color: AppColors.accent,
        child: statusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              AsyncErrorView(
                error: error,
                onRetry: () => ref.invalidate(accessibilityStatusProvider),
              ),
            ],
          ),
          data: (status) {
            return settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AsyncErrorView(error: error),
              data: (settings) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _StatusCard(
                      isEnabled: status.isEnabled,
                      enforcementEnabled:
                          settings.accessibilityEnforcementEnabled,
                      onOpenSettings: _openAccessibilitySettings,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: SwitchListTile(
                        title: const Text('Enforcement'),
                        subtitle: const Text(
                          'Block distraction apps while a task is running',
                        ),
                        value: settings.accessibilityEnforcementEnabled,
                        onChanged: status.isEnabled
                            ? (value) => _updateEnforcement(
                                  settings,
                                  value,
                                )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Blocked Apps',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When a task is running, opening these apps returns you to Discipline.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.upcoming,
                          ),
                    ),
                    const SizedBox(height: 12),
                    blockedAppsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => Text('$error'),
                      data: (apps) => _BlockedAppsList(
                        apps: apps,
                        onToggle: (app, blocked) => _toggleBlockedApp(
                          settings,
                          app,
                          blocked,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateEnforcement(
    AppSettings settings,
    bool enabled,
  ) async {
    try {
      final updated = settings.copyWith(
        accessibilityEnforcementEnabled: enabled,
      );
      await ref.read(settingsCrudProvider).update(updated);
      await ref.read(accessibilityEnforcementCoordinatorProvider).syncFromTasks(
            await ref.read(tasksStreamProvider.future),
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  Future<void> _toggleBlockedApp(
    AppSettings settings,
    BlockedApp app,
    bool blocked,
  ) async {
    final packages = List<String>.from(settings.blockedPackageNames);
    if (blocked) {
      if (!packages.contains(app.packageName)) {
        packages.add(app.packageName);
      }
    } else {
      packages.remove(app.packageName);
    }

    final updated = settings.copyWith(blockedPackageNames: packages);

    await ref.read(settingsCrudProvider).update(updated);
    await ref
        .read(accessibilityEnforcementCoordinatorProvider)
        .syncBlockedApps(packages);
    ref.invalidate(blockedAppsProvider);
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.isEnabled,
    required this.enforcementEnabled,
    required this.onOpenSettings,
  });

  final bool isEnabled;
  final bool enforcementEnabled;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final color = isEnabled ? AppColors.completed : AppColors.overdue;
    final statusText = isEnabled ? 'Enabled' : 'Disabled';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEnabled
                      ? Icons.verified_user_outlined
                      : Icons.warning_amber_rounded,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accessibility Service',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: color,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isEnabled) ...[
              const SizedBox(height: 16),
              Text(
                'Enable Discipline in Android accessibility settings to block distractions.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.upcoming,
                    ),
              ),
            ] else if (enforcementEnabled) ...[
              const SizedBox(height: 12),
              Text(
                'Enforcement is active during running tasks.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.upcoming,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onOpenSettings,
              child: Text(isEnabled ? 'Manage in Settings' : 'Enable Service'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedAppsList extends StatelessWidget {
  const _BlockedAppsList({
    required this.apps,
    required this.onToggle,
  });

  final List<BlockedApp> apps;
  final void Function(BlockedApp app, bool blocked) onToggle;

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No supported distraction apps detected on this device.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.upcoming,
              ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < apps.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            SwitchListTile(
              title: Text(apps[i].label),
              subtitle: Text(
                apps[i].packageName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.upcoming,
                    ),
              ),
              value: apps[i].isBlocked,
              onChanged: apps[i].isInstalled
                  ? (value) => onToggle(apps[i], value)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
