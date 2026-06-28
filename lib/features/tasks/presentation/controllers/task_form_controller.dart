import 'package:discipline/core/errors/exceptions.dart';
import 'package:discipline/application/providers/coordinator_providers.dart';
import 'package:discipline/features/settings/presentation/providers/settings_providers.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFormState {
  const TaskFormState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final bool isDeleting;
  final String? errorMessage;

  bool get isBusy => isSubmitting || isDeleting;

  TaskFormState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isDeleting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TaskFormController extends AutoDisposeNotifier<TaskFormState> {
  @override
  TaskFormState build() => const TaskFormState();

  Future<Task?> loadTask(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final task = await ref.read(taskCrudProvider).getById(id);
      if (task == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Task not found',
        );
        return null;
      }
      state = state.copyWith(isLoading: false);
      return task;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  Future<bool> save({
    required String? taskId,
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final crud = ref.read(taskCrudProvider);
      final coordinator = ref.read(taskAlarmCoordinatorProvider);
      final settings = await ref.read(settingsCrudProvider).get();
      Task savedTask;

      if (taskId == null) {
        savedTask = await crud.create(
          heading: heading,
          subHeading: subHeading,
          startTime: startTime,
          completionDuration: completionDuration,
        );
      } else {
        savedTask = await crud.update(
          id: taskId,
          heading: heading,
          subHeading: subHeading,
          startTime: startTime,
          completionDuration: completionDuration,
        );
      }

      await coordinator.syncTask(savedTask, settings);
      state = state.copyWith(isSubmitting: false);
      return true;
    } on ValidationException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.message,
      );
      return false;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<bool> delete(String taskId) async {
    state = state.copyWith(isDeleting: true, clearError: true);
    try {
      await ref.read(taskCrudProvider).delete(taskId);
      await ref.read(taskAlarmCoordinatorProvider).onTaskDeleted(taskId);
      state = state.copyWith(isDeleting: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isDeleting: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }
}

final taskFormControllerProvider =
    AutoDisposeNotifierProvider<TaskFormController, TaskFormState>(
  TaskFormController.new,
);

DateTime defaultTaskStartTime() {
  final now = DateTime.now();
  final base = DateTime(now.year, now.month, now.day, now.hour, now.minute);
  final remainder = base.minute % 15;
  final minutesToAdd = remainder == 0 ? 15 : 15 - remainder;
  return base.add(Duration(minutes: minutesToAdd));
}
