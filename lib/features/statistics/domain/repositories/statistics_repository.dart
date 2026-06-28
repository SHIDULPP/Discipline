import 'package:discipline/features/statistics/domain/entities/task_statistics.dart';

abstract class StatisticsRepository {
  Future<TaskStatistics> getStatistics({
    DateTime? from,
    DateTime? to,
  });
}
