import 'package:discipline/features/tasks/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAll();

  Future<TaskModel?> getById(String id);

  Future<TaskModel> save(TaskModel task);

  Future<void> delete(String id);

  Stream<List<TaskModel>> watchAll();
}
