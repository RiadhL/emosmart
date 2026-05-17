import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final List<Color> colors;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final Widget? icon;
  final List<BoxShadow>? shadows;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.colors = const [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
    this.height = 56,
    this.width,
    this.borderRadius,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w700,
    this.icon,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(18);
    final effectiveShadows = shadows ?? [
      BoxShadow(
        color: const Color(0xFF5B4FCF).withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: onPressed == null
                ? colors.map((c) => c.withOpacity(0.5)).toList()
                : colors,
          ),
          boxShadow: onPressed == null ? [] : effectiveShadows,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
