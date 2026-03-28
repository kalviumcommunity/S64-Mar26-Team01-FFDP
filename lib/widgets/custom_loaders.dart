import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const CustomLoader({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor.withOpacity(0.2)),
            ),
            _RotatingDots(
              size: size,
              color: effectiveColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RotatingDots extends StatefulWidget {
  final double size;
  final Color color;

  const _RotatingDots({required this.size, required this.color});

  @override
  State<_RotatingDots> createState() => _RotatingDotsState();
}

class _RotatingDotsState extends State<_RotatingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Stack(
        children: List.generate(3, (index) {
          final angle = (index * 2 * 3.14159 / 3);
          return Align(
            alignment: Alignment(
              0.8 * (index == 0 ? 1 : index == 1 ? -0.5 : -0.5),
              0.8 * (index == 0 ? 0 : index == 1 ? 0.866 : -0.866),
            ),
            child: Container(
              width: widget.size * 0.2,
              height: widget.size * 0.2,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}
