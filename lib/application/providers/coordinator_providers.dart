import 'package:discipline/application/coordinators/accessibility_enforcement_coordinator.dart';
import 'package:discipline/application/coordinators/task_alarm_coordinator.dart';
import 'package:discipline/features/accessibility/domain/entities/accessibility_status.dart';
import 'package:discipline/features/accessibility/domain/entities/blocked_app.dart';
import 'package:discipline/features/accessibility/presentation/providers/accessibility_providers.dart';
import 'package:discipline/features/alarms/presentation/providers/alarm_providers.dart';
import 'package:discipline/features/settings/presentation/providers/settings_providers.dart';
import 'package:discipline/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskAlarmCoordinatorProvider = Provider<TaskAlarmCoordinator>((ref) {
  return TaskAlarmCoordinator(
    alarmPlatform: ref.watch(alarmPlatformDataSourceProvider),
    scheduleAlarm: ref.watch(scheduleAlarmProvider),
    cancelAlarm: ref.watch(cancelAlarmProvider),
    getTasks: ref.watch(getTasksProvider),
    getSettings: ref.watch(getSettingsProvider),
    markTaskCompleted: ref.watch(markTaskCompletedProvider),
  );
});

final accessibilityEnforcementCoordinatorProvider =
    Provider<AccessibilityEnforcementCoordinator>((ref) {
  return AccessibilityEnforcementCoordinator(
    accessibilityRepository: ref.watch(accessibilityRepositoryProvider),
    getSettings: ref.watch(getSettingsProvider),
    getTasks: ref.watch(getTasksProvider),
  );
});

/// Reactive bridge: re-sync enforcement when tasks or settings change.
final accessibilityEnforcementSyncProvider = Provider<void>((ref) {
  ref.listen(tasksStreamProvider, (previous, next) {
    next.whenData(
      (tasks) => ref
          .read(accessibilityEnforcementCoordinatorProvider)
          .syncFromTasks(tasks),
    );
  });
  ref.listen(settingsStreamProvider, (previous, next) {
    next.whenData((_) async {
      final tasks = await ref.read(getTasksProvider)();
      await ref
          .read(accessibilityEnforcementCoordinatorProvider)
          .syncFromTasks(tasks);
    });
  });
});

final blockedAppsProvider = FutureProvider<List<BlockedApp>>((ref) async {
  ref.watch(settingsStreamProvider);
  final settings = await ref.watch(getSettingsProvider)();
  return ref.read(accessibilityRepositoryProvider).getBlockedAppCandidates(
        settings.blockedPackageNames,
      );
});

final accessibilityStatusProvider =
    FutureProvider.autoDispose<AccessibilityStatus>((ref) {
  return ref.read(getAccessibilityStatusProvider)();
});

/// Cancels native alarms whenever a task transitions to completed in Hive.
final taskAlarmSyncProvider = Provider<void>((ref) {
  ref.listen(tasksStreamProvider, (previous, next) {
    next.whenData((tasks) async {
      final coordinator = ref.read(taskAlarmCoordinatorProvider);
      final previousTasks = previous?.valueOrNull;

      for (final task in tasks.where((task) => task.isCompleted)) {
        final wasCompleted = previousTasks?.any(
              (previousTask) =>
                  previousTask.id == task.id && previousTask.isCompleted,
            ) ??
            false;
        if (!wasCompleted || previousTasks == null) {
          await coordinator.cancelForTask(task.id);
        }
      }
    });
  });
});
