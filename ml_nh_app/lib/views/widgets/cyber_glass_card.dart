import 'dart:ui';
import 'package:flutter/material.dart';

class CyberGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color glowColor;

  const CyberGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 16.0,
    this.blur = 12.0,
    this.glowColor = const Color(0xFF00FFCC),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: glowColor.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.03),
                blurRadius: 12,
                spreadRadius: 1,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
