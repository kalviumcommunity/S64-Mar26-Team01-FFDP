import 'package:flutter/material.dart';

/// A simple, reusable responsive grid system.
/// It displays children in a Column on smaller screens (mobile) and
/// attempts to layout children in a Wrap/Row structure on wider screens (tablet+).
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double breakpoint;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.breakpoint = 600.0, // Standard tablet breakpoint
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the available width is larger than the breakpoint, use a Wrap
        // to allow items to flow horizontally and wrap to the next line.
        if (constraints.maxWidth >= breakpoint) {
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            // CrossAxisAlignment controls vertical alignment in the row
            crossAxisAlignment: WrapCrossAlignment.start, 
            children: children,
          );
        } else {
          // On mobile, use a standard List-view style Column
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _addSpacingToChildren(children, spacing),
          );
        }
      },
    );
  }

  // Helper method to inject spacing between children in the Column layout
  List<Widget> _addSpacingToChildren(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;
    
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      // Add a SizedBox after everything except the last item
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }
    return spacedChildren;
  }
}
