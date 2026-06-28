import 'package:discipline/core/widgets/staggered_entrance.dart';
import 'package:flutter/material.dart';

/// Form-field entrance animation — thin wrapper over [StaggeredEntrance].
class FormEntranceAnimation extends StatelessWidget {
  const FormEntranceAnimation({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StaggeredEntrance(
      index: index,
      duration: const Duration(milliseconds: 480),
      delayPerIndex: const Duration(milliseconds: 70),
      slideOffset: const Offset(0, 0.08),
      child: child,
    );
  }
}
