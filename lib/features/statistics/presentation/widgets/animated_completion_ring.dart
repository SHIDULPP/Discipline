import 'dart:math' as math;

import 'package:discipline/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AnimatedCompletionRing extends StatefulWidget {
  const AnimatedCompletionRing({
    super.key,
    required this.completionRate,
    required this.completedTasks,
    required this.totalTasks,
  });

  final double completionRate;
  final int completedTasks;
  final int totalTasks;

  @override
  State<AnimatedCompletionRing> createState() => _AnimatedCompletionRingState();
}

class _AnimatedCompletionRingState extends State<AnimatedCompletionRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progress = Tween<double>(begin: 0, end: widget.completionRate).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCompletionRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completionRate != widget.completionRate) {
      _progress = Tween<double>(
        begin: oldWidget.completionRate,
        end: widget.completionRate,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
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
    final percent = (widget.completionRate * 100).round();

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return SizedBox(
          width: 168,
          height: 168,
          child: CustomPaint(
            painter: _RingPainter(progress: _progress.value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percent%',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.completedTasks}/${widget.totalTasks}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.upcoming,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 12.0;

    final backgroundPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.accent.withValues(alpha: 0.5),
          AppColors.accent,
          AppColors.completed,
        ],
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
