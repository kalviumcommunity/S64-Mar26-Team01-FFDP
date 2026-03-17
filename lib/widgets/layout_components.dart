import 'package:flutter/material.dart';

/// A stylized container that provides a consistent card look
/// with padding and a subtle shadow, adhering to Material 3 principles.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // We use a Material widget to enable crisp InkWell ripple effects
    // if the card is meant to be tappable.
    return Padding(
      padding: margin,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        // Subtle elevation mimicking a slight lift off the background
        elevation: 1,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
        clipBehavior: Clip.antiAlias, // Ensures child ink ripples don't bleed out
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A wrapper to be used inside Scaffold bodies to ensure consistent
/// horizontal padding and safe area constraints across different screens.
class PageContentWrapper extends StatelessWidget {
  final Widget child;
  final double horizontalPadding;
  
  const PageContentWrapper({
    Key? key,
    required this.child,
    this.horizontalPadding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: child,
      ),
    );
  }
}
