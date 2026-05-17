import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;
  final List<BoxShadow>? shadows;
  final double blurSigma;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.gradientColors,
    this.shadows,
    this.blurSigma = 10,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);
    final shadowList = shadows ?? [
      BoxShadow(
        color: const Color(0xFF5B4FCF).withOpacity(0.12),
        blurRadius: 30,
        offset: const Offset(0, 10),
        spreadRadius: 0,
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadowList,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ?? [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
