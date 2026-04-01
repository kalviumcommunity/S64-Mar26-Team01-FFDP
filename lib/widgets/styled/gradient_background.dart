import 'dart:math';
import 'package:flutter/material.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final List<double>? stops;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final bool enableNoise;
  final double noiseIntensity;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.stops,
    this.begin = Alignment.bottomCenter,
    this.end = Alignment.topCenter,
    this.enableNoise = true,
    this.noiseIntensity = 0.05,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _noiseController;

  @override
  void initState() {
    super.initState();
    _noiseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _noiseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default colors based on the "Sunset Glow" / Peach theme requested
    final bgColors = widget.colors ??
        [
          const Color.fromRGBO(245, 87, 2, 1),
          const Color.fromRGBO(245, 120, 2, 1),
          const Color.fromRGBO(245, 140, 2, 1),
          const Color.fromRGBO(245, 170, 100, 1),
          const Color.fromRGBO(238, 174, 202, 1),
          const Color.fromRGBO(202, 179, 214, 1),
          const Color.fromRGBO(148, 201, 233, 1),
        ];

    final bgStops = widget.stops ?? [0.105, 0.16, 0.175, 0.25, 0.40, 0.65, 1.0];

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.0, 1.0), // bottom-middle
          radius: 1.5,
          colors: bgColors,
          stops: bgStops,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.enableNoise)
            AnimatedBuilder(
              animation: _noiseController,
              builder: (context, child) {
                return Opacity(
                  opacity: widget.noiseIntensity,
                  child: CustomPaint(
                    painter: _NoisePainter(
                      seed: (_noiseController.value * 10).toInt(),
                    ),
                  ),
                );
              },
            ),
          SafeArea(child: widget.child),
        ],
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  final int seed;

  _NoisePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final paint = Paint()
      ..color = Colors.black
          .withOpacity(0.3); // Increased opacity slightly for contrast

    // Made step much smaller (1.5) to look like high-res film grain instead of chunky pixels
    const double step = 1.5;

    // Fixed math grid for actual grain consistency
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        if (random.nextDouble() > 0.5) {
          canvas.drawRect(Rect.fromLTWH(x, y, step, step), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}
