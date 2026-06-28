import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/repositories/task_repository.dart';

class UpdateTask {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  Future<Task> call({
    required String id,
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
  }) {
    return _repository.updateTask(
      id: id,
      heading: heading,
      subHeading: subHeading,
      startTime: startTime,
      completionDuration: completionDuration,
    );
  }
}
