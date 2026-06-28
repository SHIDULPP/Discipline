import 'package:discipline/core/errors/exceptions.dart';
import 'package:discipline/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:discipline/features/tasks/data/models/task_model.dart';
import 'package:discipline/features/tasks/data/validators/task_input_validator.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._localDataSource);

  final TaskLocalDataSource _localDataSource;
  static const _uuid = Uuid();

  @override
  Future<Task> createTask({
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
  }) async {
    TaskInputValidator.validateCreateOrUpdate(
      heading: heading,
      subHeading: subHeading,
      completionDuration: completionDuration,
    );

    final model = TaskModel(
      id: _uuid.v4(),
      heading: heading.trim(),
      subHeading: subHeading.trim(),
      startTimeMillis: startTime.millisecondsSinceEpoch,
      completionDurationMinutes: completionDuration.inMinutes,
      isCompleted: false,
    );

    final saved = await _localDataSource.save(model);
    return saved.toEntity();
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.delete(id);
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final model = await _localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Task>> getTasks() async {
    final models = await _localDataSource.getAll();
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<Task> markTaskCompleted(String id) async {
    final existing = await _localDataSource.getById(id);
    if (existing == null) {
      throw NotFoundException('Task not found: $id');
    }

    final updated = existing.copyWith(isCompleted: true);
    final saved = await _localDataSource.save(updated);
    return saved.toEntity();
  }

  @override
  Future<Task> updateTask({
    required String id,
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
  }) async {
    TaskInputValidator.validateCreateOrUpdate(
      heading: heading,
      subHeading: subHeading,
      completionDuration: completionDuration,
    );

    final existing = await _localDataSource.getById(id);
    if (existing == null) {
      throw NotFoundException('Task not found: $id');
    }

    final updated = existing.copyWith(
      heading: heading.trim(),
      subHeading: subHeading.trim(),
      startTimeMillis: startTime.millisecondsSinceEpoch,
      completionDurationMinutes: completionDuration.inMinutes,
    );

    final saved = await _localDataSource.save(updated);
    return saved.toEntity();
  }
}
