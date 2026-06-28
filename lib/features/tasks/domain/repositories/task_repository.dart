import 'package:discipline/features/tasks/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();

  Future<Task?> getTaskById(String id);

  Future<Task> createTask({
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
  });

  Future<Task> updateTask({
    required String id,
    required String heading,
    required String subHeading,
    required DateTime startTime,
    required Duration completionDuration,
  });

  Future<void> deleteTask(String id);

  Future<Task> markTaskCompleted(String id);
}
