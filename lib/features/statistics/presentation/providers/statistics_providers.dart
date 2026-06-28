import 'package:discipline/features/statistics/data/datasources/statistics_local_datasource.dart';
import 'package:discipline/features/statistics/data/datasources/statistics_local_datasource_impl.dart';
import 'package:discipline/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:discipline/features/statistics/domain/entities/task_statistics.dart';
import 'package:discipline/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:discipline/features/statistics/domain/usecases/get_statistics.dart';
import 'package:discipline/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final statisticsLocalDataSourceProvider =
    Provider<StatisticsLocalDataSource>((ref) {
  return StatisticsLocalDataSourceImpl(ref.watch(taskLocalDataSourceProvider));
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepositoryImpl(ref.watch(statisticsLocalDataSourceProvider));
});

final getStatisticsProvider = Provider<GetStatistics>((ref) {
  return GetStatistics(ref.watch(statisticsRepositoryProvider));
});

/// Recomputes whenever Hive task data changes.
final statisticsStreamProvider = StreamProvider<TaskStatistics>((ref) async* {
  final dataSource = ref.watch(statisticsLocalDataSourceProvider);
  final taskDataSource = ref.watch(taskLocalDataSourceProvider);

  yield await dataSource.computeStatistics();

  await for (final _ in taskDataSource.watchAll()) {
    yield await dataSource.computeStatistics();
  }
});
