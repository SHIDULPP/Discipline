import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/features/statistics/domain/entities/period_progress_point.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ProgressChartLabelMode { weekly, monthly }

class AnimatedProgressChart extends StatefulWidget {
  const AnimatedProgressChart({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    this.labelMode = ProgressChartLabelMode.weekly,
  });

  final String title;
  final String subtitle;
  final List<PeriodProgressPoint> points;
  final ProgressChartLabelMode labelMode;

  @override
  State<AnimatedProgressChart> createState() => _AnimatedProgressChartState();
}

class _AnimatedProgressChartState extends State<AnimatedProgressChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedProgressChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.upcoming,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 168,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < widget.points.length; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: i == 0 ? 0 : 2,
                              right: i == widget.points.length - 1 ? 0 : 2,
                            ),
                            child: _BarColumn(
                              point: widget.points[i],
                              animationValue: Curves.easeOutCubic.transform(
                                _controller.value,
                              ),
                              labelMode: widget.labelMode,
                              index: i,
                              total: widget.points.length,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.point,
    required this.animationValue,
    required this.labelMode,
    required this.index,
    required this.total,
  });

  final PeriodProgressPoint point;
  final double animationValue;
  final ProgressChartLabelMode labelMode;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTasks = point.hasTasks;
    final completionHeight = hasTasks ? point.completionRate : 0.04;
    final animatedHeight = 120 * completionHeight * animationValue;
    final barColor = hasTasks
        ? (point.completionRate >= 1
            ? AppColors.completed
            : AppColors.accent)
        : AppColors.outline.withValues(alpha: 0.35);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasTasks)
          Text(
            '${point.completedTasks}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.upcoming,
              fontSize: 10,
            ),
          )
        else
          const SizedBox(height: 14),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: animatedHeight.clamp(4, 120),
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _label(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.upcoming,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _label() {
    if (labelMode == ProgressChartLabelMode.weekly) {
      return DateFormat('E').format(point.date).substring(0, 1);
    }

    final showDay = index == 0 || index == total - 1 || point.date.day % 5 == 0;
    return showDay ? '${point.date.day}' : '';
  }
}
