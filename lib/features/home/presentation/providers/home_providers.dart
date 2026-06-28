import 'package:discipline/features/home/presentation/models/today_task_groups.dart';
import 'package:discipline/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ticks every minute so task states refresh without Hive changes.
final homeTickProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});

final todayTaskGroupsProvider = Provider<AsyncValue<TodayTaskGroups>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final tick = ref.watch(homeTickProvider);
  final now = tick.valueOrNull ?? DateTime.now();

  return tasksAsync.when(
    data: (tasks) => AsyncData(TodayTaskGroups.fromTasks(tasks, now: now)),
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
  );
});

final homeStatisticsProvider = Provider<AsyncValue<HomeStatistics>>((ref) {
  final groupsAsync = ref.watch(todayTaskGroupsProvider);
  return groupsAsync.when(
    data: (groups) => AsyncData(HomeStatistics.fromGroups(groups)),
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
  );
});
