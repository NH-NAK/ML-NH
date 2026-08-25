import 'package:flutter/material.dart';

class CyberPulsingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const CyberPulsingIndicator({
    super.key,
    required this.color,
    this.size = 10.0,
  });

  @override
  State<CyberPulsingIndicator> createState() => _CyberPulsingIndicatorState();
}

class _CyberPulsingIndicatorState extends State<CyberPulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 2.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.7),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value / 3,
              ),
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: _glowAnimation.value * 2,
                spreadRadius: _glowAnimation.value / 2,
              )
            ],
          ),
        );
      },
    );
  }
}
