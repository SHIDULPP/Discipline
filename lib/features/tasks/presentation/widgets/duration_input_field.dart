import 'package:discipline/core/constants/app_constants.dart';
import 'package:discipline/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DurationInputField extends StatelessWidget {
  const DurationInputField({
    super.key,
    required this.hours,
    required this.minutes,
    required this.onChanged,
    this.errorText,
  });

  final int hours;
  final int minutes;
  final void Function(int hours, int minutes) onChanged;
  final String? errorText;

  static const _presets = [
    (label: '15m', hours: 0, minutes: 15),
    (label: '30m', hours: 0, minutes: 30),
    (label: '45m', hours: 0, minutes: 45),
    (label: '1h', hours: 1, minutes: 0),
    (label: '2h', hours: 2, minutes: 0),
  ];

  void _updateHours(int delta) {
    final next = (hours + delta).clamp(0, 23);
    onChanged(next, minutes);
  }

  void _updateMinutes(int delta) {
    var nextMinutes = minutes + delta;
    var nextHours = hours;
    while (nextMinutes < 0) {
      nextMinutes += 60;
      nextHours -= 1;
    }
    while (nextMinutes >= 60) {
      nextMinutes -= 60;
      nextHours += 1;
    }
    nextHours = nextHours.clamp(0, 23);
    if (nextHours == 23 && nextMinutes > 59) nextMinutes = 59;
    onChanged(nextHours, nextMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalMinutes = (hours * 60) + minutes;
    final isOverLimit =
        totalMinutes > AppConstants.maxCompletionDurationMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: errorText != null || isOverLimit
                ? Border.all(color: AppColors.overdue.withValues(alpha: 0.6))
                : null,
          ),
          child: Row(
            children: [
              Expanded(child: _StepperColumn(
                label: 'Hours',
                value: hours,
                onDecrement: () => _updateHours(-1),
                onIncrement: () => _updateHours(1),
              )),
              Container(
                width: 1,
                height: 72,
                color: AppColors.outline,
              ),
              Expanded(child: _StepperColumn(
                label: 'Minutes',
                value: minutes,
                onDecrement: () => _updateMinutes(-15),
                onIncrement: () => _updateMinutes(15),
              )),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.overdue),
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets.map((preset) {
            final isSelected =
                hours == preset.hours && minutes == preset.minutes;
            return AnimatedScale(
              scale: isSelected ? 1.02 : 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: FilterChip(
                label: Text(preset.label),
                selected: isSelected,
                onSelected: (_) => onChanged(preset.hours, preset.minutes),
                showCheckmark: false,
                selectedColor: AppColors.accent.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.accent : AppColors.primary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.accent : AppColors.outline,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StepperColumn extends StatelessWidget {
  const _StepperColumn({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.upcoming,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepperButton(
              icon: Icons.remove_rounded,
              onPressed: onDecrement,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: SizedBox(
                key: ValueKey(value),
                width: 48,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            _StepperButton(
              icon: Icons.add_rounded,
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
      ),
    );
  }
}
