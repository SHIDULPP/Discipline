import 'package:discipline/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class SettingsUiConstants {
  static const reminderIntervalOptions = [1, 3, 5, 10, 15, 30];
}

String formatReminderInterval(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes == 1) return '1 minute';
  return '$minutes minutes';
}

Color permissionStatusColor(bool isGranted) {
  return isGranted ? AppColors.completed : AppColors.overdue;
}

String permissionStatusLabel(bool isGranted, {required String granted, required String denied}) {
  return isGranted ? granted : denied;
}
