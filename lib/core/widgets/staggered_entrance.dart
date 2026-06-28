import 'package:flutter/material.dart';

/// Reusable staggered fade + slide entrance animation.
///
/// Disposes its [AnimationController] automatically. Prefer a single shared
/// widget over copying private `_AnimatedEntrance` implementations.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.delayPerIndex = const Duration(milliseconds: 60),
    this.slideOffset = const Offset(0, 0.06),
    this.scaleBegin,
  });

  final int index;
  final Widget child;
  final Duration duration;
  final Duration delayPerIndex;
  final Offset slideOffset;
  final double? scaleBegin;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late Animation<Offset> _slide;
  Animation<double>? _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: widget.slideOffset, end: Offset.zero)
        .animate(_fade);
    if (widget.scaleBegin != null) {
      _scale = Tween<double>(begin: widget.scaleBegin, end: 1).animate(_fade);
    }

    Future<void>.delayed(widget.delayPerIndex * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (_scale != null) {
      child = ScaleTransition(scale: _scale!, child: child);
    }

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: child),
    );
  }
}
