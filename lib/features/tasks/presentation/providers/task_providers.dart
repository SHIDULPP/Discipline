import 'package:discipline/core/services/hive_service.dart';
import 'package:discipline/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:discipline/features/tasks/data/datasources/task_local_datasource_impl.dart';
import 'package:discipline/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/repositories/task_repository.dart';
import 'package:discipline/features/tasks/domain/usecases/create_task.dart';
import 'package:discipline/features/tasks/domain/usecases/delete_task.dart';
import 'package:discipline/features/tasks/domain/usecases/get_task_by_id.dart';
import 'package:discipline/features/tasks/domain/usecases/get_tasks.dart';
import 'package:discipline/features/tasks/domain/usecases/mark_task_completed.dart';
import 'package:discipline/features/tasks/domain/usecases/update_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Data layer ──────────────────────────────────────────────────────────────

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return TaskLocalDataSourceImpl(hiveService);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskLocalDataSourceProvider));
});

// ── Use cases ─────────────────────────────────────────────────────────────────

final getTasksProvider = Provider<GetTasks>((ref) {
  return GetTasks(ref.watch(taskRepositoryProvider));
});

final getTaskByIdProvider = Provider<GetTaskById>((ref) {
  return GetTaskById(ref.watch(taskRepositoryProvider));
});

final createTaskProvider = Provider<CreateTask>((ref) {
  return CreateTask(ref.watch(taskRepositoryProvider));
});

final updateTaskProvider = Provider<UpdateTask>((ref) {
  return UpdateTask(ref.watch(taskRepositoryProvider));
});

final deleteTaskProvider = Provider<DeleteTask>((ref) {
  return DeleteTask(ref.watch(taskRepositoryProvider));
});

final markTaskCompletedProvider = Provider<MarkTaskCompleted>((ref) {
  return MarkTaskCompleted(ref.watch(taskRepositoryProvider));
});

// ── Reactive streams ──────────────────────────────────────────────────────────

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final dataSource = ref.watch(taskLocalDataSourceProvider);
  return dataSource.watchAll().map(
        (models) =>
            models.map((model) => model.toEntity()).toList(growable: false),
      );
});

final taskByIdProvider = FutureProvider.family<Task?, String>((ref, id) async {
  return ref.watch(getTaskByIdProvider)(id);
});

// ── CRUD facade ─────────────────────────────────────────────────────────────────

final taskCrudProvider = Provider<TaskCrud>((ref) => TaskCrud(ref));

class TaskCrud {
  const TaskCrud(this._ref);

  final Ref _ref;

  Future<List<Task>> getAll() => _ref.read(getTasksProvider)();

  Future<Task?> getById(String id) => _ref.read(getTaskByIdProvider)(id);

  Future<Task> create({
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
  }) {
    return _ref.read(createTaskProvider)(
      heading: heading,
      subHeading: subHeading,
      startTime: startTime,
      completionDuration: completionDuration,
    );
  }

  Future<Task> update({
    required String id,
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
  }) {
    return _ref.read(updateTaskProvider)(
      id: id,
      heading: heading,
      subHeading: subHeading,
      startTime: startTime,
      completionDuration: completionDuration,
    );
  }

  Future<void> delete(String id) => _ref.read(deleteTaskProvider)(id);

  Future<Task> markCompleted(String id) =>
      _ref.read(markTaskCompletedProvider)(id);
}
