import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/core/widgets/staggered_entrance.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/presentation/utils/task_display_utils.dart';
import 'package:flutter/material.dart';

class AnimatedTaskCard extends StatelessWidget {
  const AnimatedTaskCard({
    super.key,
    required this.task,
    required this.animationIndex,
    this.onTap,
    this.onComplete,
  });

  final Task task;
  final int animationIndex;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final stateColor = TaskDisplayUtils.stateColor(task.state);

    return StaggeredEntrance(
      index: animationIndex,
      duration: const Duration(milliseconds: 420),
      delayPerIndex: const Duration(milliseconds: 50),
      slideOffset: const Offset(0, 0.1),
      scaleBegin: 0.96,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: stateColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _StateChip(
                                label: TaskDisplayUtils.stateLabel(task.state),
                                color: stateColor,
                              ),
                              const Spacer(),
                              Text(
                                TaskDisplayUtils.formatStartTime(task.startTime),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: AppColors.upcoming),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            task.heading,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (task.subHeading.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.subHeading,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.upcoming),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 10),
                          Text(
                            'Duration · ${TaskDisplayUtils.formatDuration(task.completionDuration)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.upcoming),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onComplete != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Center(
                        child: IconButton.filledTonal(
                          tooltip: 'Mark complete',
                          onPressed: onComplete,
                          icon: const Icon(Icons.check_rounded, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
      ),
    );
  }
}
