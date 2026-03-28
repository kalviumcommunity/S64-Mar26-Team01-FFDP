import 'package:flutter/material.dart';

/// A highly optimized Like button animation.
/// Uses a StatefulWidget internally to handle its own AnimationController
/// but exposes a simple stateless-like API to consumers.
class AnimatedLikeButton extends StatefulWidget {
  final bool initialIsLiked;
  final double size;
  final ValueChanged<bool>? onToggle;
  final Color likedColor;
  final Color unlikedColor;

  const AnimatedLikeButton({
    Key? key,
    this.initialIsLiked = false,
    this.size = 28.0,
    this.onToggle,
    this.likedColor = Colors.red,
    this.unlikedColor = Colors.grey,
  }) : super(key: key);

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;

    _controller = AnimationController(
       duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Creates a pop/bounce effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      _controller.forward(from: 0.0);
    } // typically unlike doesn't bounce in many apps, so we skip reverse animation

    if (widget.onToggle != null) {
      widget.onToggle!(_isLiked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We use AnimatedBuilder exclusively on the icon to avoid full widget rebuilds during animation
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isLiked ? _scaleAnimation.value : 1.0,
              child: child,
            );
          },
          child: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? widget.likedColor : widget.unlikedColor,
            size: widget.size,
          ),
        ),
      ),
    );
  }
}
