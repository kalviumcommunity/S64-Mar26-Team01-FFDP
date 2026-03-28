import 'package:flutter/material.dart';

/// CHOICE: StatefulWidget
/// RATIONALE: This widget needs to manage its own "isLiked" state and
/// handle a toggle animation when the user interacts with it. Because
/// the widget reacts to user events by updating its own UI, a
/// StatefulWidget is required to hold the mutable state.
class StatefulLikeButton extends StatefulWidget {
  final bool initialIsLiked;
  final Function(bool)? onToggle;

  const StatefulLikeButton({
    super.key,
    this.initialIsLiked = false,
    this.onToggle,
  });

  @override
  State<StatefulLikeButton> createState() => _StatefulLikeButtonState();
}

class _StatefulLikeButtonState extends State<StatefulLikeButton>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;

    // Animation for a slight "pop" effect when liked
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  void _handleTap() {
    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      _controller.forward(from: 0.0);
    }

    if (widget.onToggle != null) {
      widget.onToggle!(_isLiked);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          color: _isLiked ? Colors.red : Colors.grey,
        ),
        onPressed: _handleTap,
        tooltip: _isLiked ? 'Unlike' : 'Like',
      ),
    );
  }
}
