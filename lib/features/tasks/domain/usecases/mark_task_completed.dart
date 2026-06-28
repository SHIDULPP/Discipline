import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/repositories/task_repository.dart';

class MarkTaskCompleted {
  const MarkTaskCompleted(this._repository);

  final TaskRepository _repository;

  Future<Task> call(String id) => _repository.markTaskCompleted(id);
}
