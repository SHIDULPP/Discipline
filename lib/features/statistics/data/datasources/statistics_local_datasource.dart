import 'package:discipline/features/statistics/domain/entities/task_statistics.dart';

abstract class StatisticsLocalDataSource {
  Future<TaskStatistics> computeStatistics({
    DateTime? from,
    DateTime? to,
  });
}
