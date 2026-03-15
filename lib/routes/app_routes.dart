import 'package:flutter/material.dart';
import '../screens/devtools_demo_screen.dart';

/// Centralized route definitions for the NanheNest app.
class AppRoutes {
  AppRoutes._();

  static const String devToolsDemo = '/devtools-demo';

  static Map<String, WidgetBuilder> get routes => {
        devToolsDemo: (_) => const DevToolsDemoScreen(),
      };
}
