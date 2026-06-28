import 'package:discipline/features/statistics/domain/entities/task_statistics.dart';
import 'package:discipline/features/statistics/domain/repositories/statistics_repository.dart';

class GetStatistics {
  const GetStatistics(this._repository);

  final StatisticsRepository _repository;

  Future<TaskStatistics> call({DateTime? from, DateTime? to}) {
    return _repository.getStatistics(from: from, to: to);
  }
}
