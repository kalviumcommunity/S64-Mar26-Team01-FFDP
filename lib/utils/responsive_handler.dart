import 'package:flutter/material.dart';

/// A utility class for handling responsive design breakpoints.
class ResponsiveHandler {
  // Standard Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1200.0;

  /// Returns true if the screen width is less than [mobileBreakpoint].
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Returns true if the screen width is between [mobileBreakpoint] and [tabletBreakpoint].
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Returns true if the screen width is greater than or equal to [tabletBreakpoint].
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
}

/// A widget that builds different layouts based on the screen width using LayoutBuilder.
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveHandler.tabletBreakpoint &&
            desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= ResponsiveHandler.mobileBreakpoint &&
            tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}
