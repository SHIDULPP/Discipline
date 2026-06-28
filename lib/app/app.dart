import 'package:discipline/application/providers/coordinator_providers.dart';
import 'package:discipline/core/routing/router_provider.dart';
import 'package:discipline/core/theme/app_theme.dart';
import 'package:discipline/features/settings/presentation/providers/device_permissions_provider.dart';
import 'package:discipline/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DisciplineApp extends ConsumerStatefulWidget {
  const DisciplineApp({super.key});

  @override
  ConsumerState<DisciplineApp> createState() => _DisciplineAppState();
}

class _DisciplineAppState extends ConsumerState<DisciplineApp>
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
      ref.read(taskAlarmCoordinatorProvider).processPendingCompletions();
      ref.read(accessibilityEnforcementCoordinatorProvider).initialize();
      ref.invalidate(accessibilityStatusProvider);
      ref.invalidate(devicePermissionsStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(accessibilityEnforcementSyncProvider);
    ref.watch(taskAlarmSyncProvider);
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsStreamProvider).valueOrNull;
    final darkTheme = settings?.darkThemeEnabled ?? true;
    final themeMode = darkTheme ? ThemeMode.dark : ThemeMode.light;

    return MaterialApp.router(
      title: 'Discipline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
