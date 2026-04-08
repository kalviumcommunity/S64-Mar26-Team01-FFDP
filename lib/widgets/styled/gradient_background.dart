import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF071013), // Ink Black
            Color(0xFFB3C2F2), // Periwinkle
            Color(0xFFCACCE3), // Lavender
            Color(0xFFF3F7F6), // Platinum
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
