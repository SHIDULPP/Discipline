import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/repositories/task_repository.dart';

class CreateTask {
  const CreateTask(this._repository);

  final TaskRepository _repository;

  Future<Task> call({
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
  }) {
    return _repository.createTask(
      heading: heading,
      subHeading: subHeading,
      startTime: startTime,
      completionDuration: completionDuration,
    );
  }
}
