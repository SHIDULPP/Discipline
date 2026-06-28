import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/features/tasks/domain/entities/task_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Presentation helpers for rendering task metadata.
abstract final class TaskDisplayUtils {
  static String todayHeading(DateTime now) {
    return DateFormat('EEEE, MMMM d').format(now);
  }

  static String formatStartTime(DateTime startTime) {
    return DateFormat.jm().format(startTime);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  static String stateLabel(TaskState state) {
    return switch (state) {
      TaskState.upcoming => 'Upcoming',
      TaskState.running => 'Running',
      TaskState.overdue => 'Overdue',
      TaskState.completed => 'Completed',
    };
  }

  static Color stateColor(TaskState state) {
    return switch (state) {
      TaskState.upcoming => AppColors.upcoming,
      TaskState.running => AppColors.running,
      TaskState.overdue => AppColors.overdue,
      TaskState.completed => AppColors.completed,
    };
  }
}
