import 'package:discipline/app/app.dart';
import 'package:discipline/core/services/hive_service.dart';
import 'package:discipline/features/accessibility/presentation/providers/accessibility_providers.dart';
import 'package:discipline/features/alarms/presentation/providers/alarm_providers.dart';
import 'package:discipline/application/providers/coordinator_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final alarmPlatform = createAlarmPlatformDataSource();
  final accessibilityPlatform = createAccessibilityPlatformDataSource();

  final container = ProviderContainer(
    overrides: [
      hiveServiceProvider.overrideWithValue(hiveService),
      alarmPlatformDataSourceProvider.overrideWithValue(alarmPlatform),
      accessibilityPlatformDataSourceProvider.overrideWithValue(
        accessibilityPlatform,
      ),
    ],
  );

  await container.read(taskAlarmCoordinatorProvider).initialize();
  await container
      .read(accessibilityEnforcementCoordinatorProvider)
      .initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DisciplineApp(),
    ),
  );
}
