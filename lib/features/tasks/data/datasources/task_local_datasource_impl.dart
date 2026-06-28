import 'package:discipline/core/data/hive_error_mapper.dart';
import 'package:discipline/core/errors/exceptions.dart';
import 'package:discipline/core/services/hive_service.dart';
import 'package:discipline/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:discipline/features/tasks/data/models/task_model.dart';

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(this._hiveService);

  final HiveService _hiveService;

  @override
  Future<List<TaskModel>> getAll() async {
    try {
      return _sortedValues();
    } catch (error) {
      HiveErrorMapper.rethrowAsCacheException(error, 'Failed to read tasks');
    }
  }

  @override
  Future<TaskModel?> getById(String id) async {
    try {
      return _hiveService.tasksBox.get(id);
    } catch (error) {
      HiveErrorMapper.rethrowAsCacheException(error, 'Failed to read task');
    }
  }

  @override
  Future<TaskModel> save(TaskModel task) async {
    try {
      await _hiveService.tasksBox.put(task.id, task);
      final saved = _hiveService.tasksBox.get(task.id);
      if (saved == null) {
        throw const CacheException('Failed to persist task');
      }
      return saved;
    } catch (error) {
      HiveErrorMapper.rethrowAsCacheException(error, 'Failed to save task');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (!_hiveService.tasksBox.containsKey(id)) {
        throw NotFoundException('Task not found: $id');
      }
      await _hiveService.tasksBox.delete(id);
    } catch (error) {
      HiveErrorMapper.rethrowAsCacheException(error, 'Failed to delete task');
    }
  }

  @override
  Stream<List<TaskModel>> watchAll() async* {
    yield _sortedValues();
    await for (final _ in _hiveService.tasksBox.watch()) {
      yield _sortedValues();
    }
  }

  List<TaskModel> _sortedValues() {
    final tasks = _hiveService.tasksBox.values.toList(growable: false)
      ..sort((a, b) => a.startTimeMillis.compareTo(b.startTimeMillis));
    return tasks;
  }
}
