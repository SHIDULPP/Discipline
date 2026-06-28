import 'package:discipline/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shared linear completion indicator used on home and statistics screens.
class CompletionProgressBar extends StatelessWidget {
  const CompletionProgressBar({
    super.key,
    required this.completionRate,
    this.minHeight = 8,
  });

  final double completionRate;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: completionRate.clamp(0, 1),
        minHeight: minHeight,
        backgroundColor: AppColors.surfaceVariant,
        color: AppColors.accent,
      ),
    );
  }
}
