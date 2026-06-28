import 'package:discipline/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:discipline/features/statistics/domain/entities/task_statistics.dart';
import 'package:discipline/features/statistics/domain/services/statistics_calculator.dart';
import 'package:discipline/features/tasks/data/datasources/task_local_datasource.dart';

class StatisticsLocalDataSourceImpl implements StatisticsLocalDataSource {
  StatisticsLocalDataSourceImpl(this._taskDataSource);

  final TaskLocalDataSource _taskDataSource;

  @override
  Future<TaskStatistics> computeStatistics({
    DateTime? from,
    DateTime? to,
  }) async {
    final models = await _taskDataSource.getAll();
    final tasks = models.map((model) => model.toEntity()).toList(growable: false);
    return StatisticsCalculator.compute(tasks, from: from, to: to);
  }
}
