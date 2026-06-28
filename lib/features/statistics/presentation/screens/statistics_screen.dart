import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/core/widgets/async_error_view.dart';
import 'package:discipline/core/widgets/staggered_entrance.dart';
import 'package:discipline/features/statistics/domain/entities/task_statistics.dart';
import 'package:discipline/features/statistics/presentation/providers/statistics_providers.dart';
import 'package:discipline/features/statistics/presentation/widgets/animated_completion_ring.dart';
import 'package:discipline/features/statistics/presentation/widgets/animated_progress_chart.dart';
import 'package:discipline/features/statistics/presentation/widgets/statistics_summary_cards.dart';
import 'package:discipline/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(statisticsStreamProvider),
        ),
        data: (stats) => _StatisticsBody(statistics: stats),
      ),
    );
  }
}

class _StatisticsBody extends ConsumerWidget {
  const _StatisticsBody({required this.statistics});

  final TaskStatistics statistics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(tasksStreamProvider);
        await ref.read(statisticsStreamProvider.future);
      },
      color: AppColors.accent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 640;
          final horizontalPadding = constraints.maxWidth >= 720 ? 32.0 : 16.0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  32,
                ),
                children: [
                  StaggeredEntrance(
                    index: 0,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedCompletionRing(
                                    completionRate: statistics.completionRate,
                                    completedTasks: statistics.completedTasks,
                                    totalTasks: statistics.totalTasks,
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: StatisticsOverviewSection(
                                      completionRate: statistics.completionRate,
                                      completedTasks: statistics.completedTasks,
                                      totalTasks: statistics.totalTasks,
                                      overdueTasks: statistics.overdueTasks,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  AnimatedCompletionRing(
                                    completionRate: statistics.completionRate,
                                    completedTasks: statistics.completedTasks,
                                    totalTasks: statistics.totalTasks,
                                  ),
                                  const SizedBox(height: 24),
                                  StatisticsOverviewSection(
                                    completionRate: statistics.completionRate,
                                    completedTasks: statistics.completedTasks,
                                    totalTasks: statistics.totalTasks,
                                    overdueTasks: statistics.overdueTasks,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, innerConstraints) {
                      final useRow = innerConstraints.maxWidth >= 560;
                      final streakCards = [
                        StreakSummaryCard(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Current Streak',
                          value: statistics.currentStreak,
                          subtitle: _streakLabel(statistics.currentStreak),
                          color: AppColors.overdue,
                          animationIndex: 1,
                        ),
                        StreakSummaryCard(
                          icon: Icons.emoji_events_outlined,
                          label: 'Longest Streak',
                          value: statistics.longestStreak,
                          subtitle: _streakLabel(statistics.longestStreak),
                          color: AppColors.completed,
                          animationIndex: 2,
                        ),
                      ];

                      if (useRow) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: streakCards[0]),
                            const SizedBox(width: 8),
                            Expanded(child: streakCards[1]),
                          ],
                        );
                      }

                      return Column(children: streakCards);
                    },
                  ),
                  const SizedBox(height: 8),
                  StaggeredEntrance(
                    index: 3,
                    child: AnimatedProgressChart(
                      title: 'Weekly Progress',
                      subtitle: 'Daily completion over the last 7 days',
                      points: statistics.weeklyProgress,
                      labelMode: ProgressChartLabelMode.weekly,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StaggeredEntrance(
                    index: 4,
                    child: AnimatedProgressChart(
                      title: 'Monthly Progress',
                      subtitle: 'Daily completion over the last 30 days',
                      points: statistics.monthlyProgress,
                      labelMode: ProgressChartLabelMode.monthly,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _streakLabel(int days) {
    if (days == 0) return 'No perfect days yet';
    if (days == 1) return '1 perfect day';
    return '$days perfect days in a row';
  }
}
