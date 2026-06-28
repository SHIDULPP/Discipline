import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/features/tasks/domain/entities/task.dart';
import 'package:discipline/features/tasks/domain/entities/task_state.dart';
import 'package:discipline/features/tasks/presentation/widgets/animated_task_card.dart';
import 'package:flutter/material.dart';

class TaskSection extends StatelessWidget {
  const TaskSection({
    super.key,
    required this.title,
    required this.tasks,
    required this.baseAnimationIndex,
    this.onTaskTap,
    this.onTaskComplete,
  });

  final String title;
  final List<Task> tasks;
  final int baseAnimationIndex;
  final ValueChanged<Task>? onTaskTap;
  final ValueChanged<Task>? onTaskComplete;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.upcoming,
                      ),
                ),
              ),
            ],
          ),
        ),
        ...tasks.asMap().entries.map(
              (entry) => AnimatedTaskCard(
                task: entry.value,
                animationIndex: baseAnimationIndex + entry.key + 1,
                onTap: onTaskTap != null ? () => onTaskTap!(entry.value) : null,
                onComplete: entry.value.state != TaskState.completed &&
                        onTaskComplete != null
                    ? () => onTaskComplete!(entry.value)
                    : null,
              ),
            ),
      ],
    );
  }
}
