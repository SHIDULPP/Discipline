import 'package:discipline/core/constants/route_paths.dart';
import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/core/widgets/completion_progress_bar.dart';
import 'package:discipline/core/widgets/staggered_entrance.dart';
import 'package:discipline/features/home/presentation/models/today_task_groups.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeStatisticsCard extends StatelessWidget {
  const HomeStatisticsCard({
    super.key,
    required this.statistics,
    this.animationIndex = 0,
  });

  final HomeStatistics statistics;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (statistics.completionRate * 100).round();

    return StaggeredEntrance(
      index: animationIndex,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Today\'s Progress',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RoutePaths.statistics),
                    child: const Text('Details'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$percent%',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'completed',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.upcoming,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CompletionProgressBar(
                completionRate:
                    statistics.totalTasks == 0 ? 0 : statistics.completionRate,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 360;
                  final stats = [
                    _StatItem(
                      label: 'Total',
                      value: '${statistics.totalTasks}',
                      color: AppColors.primary,
                    ),
                    _StatItem(
                      label: 'Running',
                      value: '${statistics.runningTasks}',
                      color: AppColors.running,
                    ),
                    _StatItem(
                      label: 'Upcoming',
                      value: '${statistics.upcomingTasks}',
                      color: AppColors.upcoming,
                    ),
                    _StatItem(
                      label: 'Done',
                      value: '${statistics.completedTasks}',
                      color: AppColors.completed,
                    ),
                  ];

                  if (isCompact) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: stats
                          .map((item) => SizedBox(
                                width: (constraints.maxWidth - 12) / 2,
                                child: item,
                              ))
                          .toList(),
                    );
                  }

                  return Row(
                    children: stats
                        .map((item) => Expanded(child: item))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.upcoming,
              ),
        ),
      ],
    );
  }
}
