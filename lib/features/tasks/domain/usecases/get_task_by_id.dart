import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/repositories/task_repository.dart';

class GetTaskById {
  const GetTaskById(this._repository);

  final TaskRepository _repository;

  Future<Task?> call(String id) => _repository.getTaskById(id);
}
