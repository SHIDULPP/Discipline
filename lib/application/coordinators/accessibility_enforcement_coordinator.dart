import 'package:discipline/features/accessibility/domain/repositories/accessibility_repository.dart';
import 'package:discipline/features/settings/domain/usecases/get_settings.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/entities/task_state.dart';
import 'package:discipline/features/tasks/domain/usecases/get_tasks.dart';

/// Keeps native accessibility enforcement aligned with tasks and settings.
class AccessibilityEnforcementCoordinator {
  AccessibilityEnforcementCoordinator({
    required AccessibilityRepository accessibilityRepository,
    required GetSettings getSettings,
    required GetTasks getTasks,
  })  : _accessibilityRepository = accessibilityRepository,
        _getSettings = getSettings,
        _getTasks = getTasks;

  final AccessibilityRepository _accessibilityRepository;
  final GetSettings _getSettings;
  final GetTasks _getTasks;

  Future<void> initialize() async {
    final tasks = await _getTasks();
    await syncFromTasks(tasks);
  }

  Future<void> syncFromTasks(List<Task> tasks) async {
    final settings = await _getSettings();
    await syncBlockedApps(settings.blockedPackageNames);

    final runningTask = _findRunningTask(tasks);
    await _accessibilityRepository.syncEnforcementState(
      enforcementEnabled: settings.accessibilityEnforcementEnabled,
      isTaskRunning: runningTask != null,
      activeTaskId: runningTask?.id,
    );
  }

  Future<void> syncBlockedApps(List<String> packages) {
    return _accessibilityRepository.syncBlockedApps(packages);
  }

  Task? _findRunningTask(List<Task> tasks) {
    for (final task in tasks) {
      if (!task.isCompleted && task.state == TaskState.running) {
        return task;
      }
    }
    return null;
  }
}
