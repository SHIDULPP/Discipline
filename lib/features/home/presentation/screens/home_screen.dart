import 'package:discipline/application/providers/coordinator_providers.dart';
import 'package:discipline/core/constants/route_paths.dart';
import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/core/widgets/async_error_view.dart';
import 'package:discipline/features/home/presentation/models/today_task_groups.dart';
import 'package:discipline/features/home/presentation/providers/home_providers.dart';
import 'package:discipline/features/home/presentation/utils/task_display_utils.dart';
import 'package:discipline/features/home/presentation/widgets/home_statistics_card.dart';
import 'package:discipline/features/home/presentation/widgets/task_section.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(todayTaskGroupsProvider);
    final statsAsync = ref.watch(homeStatisticsProvider);
    final now = ref.watch(homeTickProvider).valueOrNull ?? DateTime.now();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.taskCreate),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
      body: SafeArea(
        child: groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AsyncErrorView(
            error: error,
            onRetry: () => ref.invalidate(tasksStreamProvider),
          ),
          data: (groups) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(tasksStreamProvider);
                await ref.read(tasksStreamProvider.future);
              },
              color: AppColors.accent,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  final horizontalPadding = isWide ? 32.0 : 16.0;

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 840 : double.infinity,
                      ),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              16,
                              horizontalPadding,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _HomeHeader(
                                dateLabel: TaskDisplayUtils.todayHeading(now),
                                onSettings: () =>
                                    context.push(RoutePaths.settings),
                                onStatistics: () =>
                                    context.push(RoutePaths.statistics),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: statsAsync.when(
                                data: (stats) =>
                                    HomeStatisticsCard(statistics: stats),
                                loading: () => const Card(
                                  child: SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                                error: (_, _) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              8,
                              horizontalPadding,
                              96,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: groups.all.isEmpty
                                  ? _EmptyToday(
                                      onCreate: () =>
                                          context.push(RoutePaths.taskCreate),
                                    )
                                  : _TodayTasksBody(
                                      groups: groups,
                                      onTaskTap: (task) => context.push(
                                        RoutePaths.taskEditPath(task.id),
                                      ),
                                      onTaskComplete: (task) =>
                                          _completeTask(ref, context, task),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _completeTask(
    WidgetRef ref,
    BuildContext context,
    Task task,
  ) async {
    try {
      await ref.read(taskCrudProvider).markCompleted(task.id);
      await ref.read(taskAlarmCoordinatorProvider).cancelForTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${task.heading}" marked complete'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not complete task: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.dateLabel,
    required this.onSettings,
    required this.onStatistics,
  });

  final String dateLabel;
  final VoidCallback onSettings;
  final VoidCallback onStatistics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discipline',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.upcoming,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Statistics',
            onPressed: onStatistics,
            icon: const Icon(Icons.bar_chart_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}

class _TodayTasksBody extends StatelessWidget {
  const _TodayTasksBody({
    required this.groups,
    required this.onTaskTap,
    required this.onTaskComplete,
  });

  final TodayTaskGroups groups;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onTaskComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Tasks',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        TaskSection(
          title: 'Upcoming',
          tasks: groups.upcoming,
          baseAnimationIndex: 1,
          onTaskTap: onTaskTap,
          onTaskComplete: onTaskComplete,
        ),
        TaskSection(
          title: 'Running',
          tasks: groups.running,
          baseAnimationIndex: 10,
          onTaskTap: onTaskTap,
          onTaskComplete: onTaskComplete,
        ),
        TaskSection(
          title: 'Completed',
          tasks: groups.completed,
          baseAnimationIndex: 20,
          onTaskTap: onTaskTap,
        ),
      ],
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 56,
            color: AppColors.upcoming.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks scheduled for today',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a task to start building discipline.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.upcoming,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: onCreate,
            child: const Text('Create Task'),
          ),
        ],
      ),
    );
  }
}