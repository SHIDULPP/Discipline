import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/core/widgets/completion_progress_bar.dart';
import 'package:discipline/core/widgets/staggered_entrance.dart';
import 'package:flutter/material.dart';

class StreakSummaryCard extends StatelessWidget {
  const StreakSummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    this.animationIndex = 0,
  });

  final IconData icon;
  final String label;
  final int value;
  final String subtitle;
  final Color color;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.upcoming,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '$value',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.upcoming,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsOverviewSection extends StatelessWidget {
  const StatisticsOverviewSection({
    super.key,
    required this.completionRate,
    required this.completedTasks,
    required this.totalTasks,
    required this.overdueTasks,
  });

  final double completionRate;
  final int completedTasks;
  final int totalTasks;
  final int overdueTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completion Rate',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'All-time task completion from Hive',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.upcoming,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _OverviewStat(
              label: 'Completed',
              value: '$completedTasks',
              color: AppColors.completed,
            ),
            _OverviewStat(
              label: 'Total',
              value: '$totalTasks',
              color: AppColors.primary,
            ),
            _OverviewStat(
              label: 'Overdue',
              value: '$overdueTasks',
              color: AppColors.overdue,
            ),
          ],
        ),
        const SizedBox(height: 16),
        CompletionProgressBar(
          completionRate: totalTasks == 0 ? 0 : completionRate,
        ),
      ],
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.upcoming,
                ),
          ),
        ],
      ),
    );
  }
}
