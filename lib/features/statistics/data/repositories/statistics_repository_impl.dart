import 'package:discipline/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:discipline/features/statistics/domain/entities/task_statistics.dart';
import 'package:discipline/features/statistics/domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl(this._localDataSource);

  final StatisticsLocalDataSource _localDataSource;

  @override
  Future<TaskStatistics> getStatistics({DateTime? from, DateTime? to}) {
    return _localDataSource.computeStatistics(from: from, to: to);
  }
}
