import 'package:flutter/material.dart';

class StaggeredSlideFadeTransition extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const StaggeredSlideFadeTransition({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 40),
  });

  @override
  State<StaggeredSlideFadeTransition> createState() => _StaggeredSlideFadeTransitionState();
}

class _StaggeredSlideFadeTransitionState extends State<StaggeredSlideFadeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Clamp the index to prevent long delay times on lower items
    final int delayFactor = widget.index.clamp(0, 10);
    Future.delayed(widget.delay * delayFactor, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
