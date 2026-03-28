import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final IconData? iconData;
  final String? assetPath;
  final Color? color;
  final double size;

  // Constructor for Material Icons
  const AppIcon.material(
    this.iconData, {
    Key? key,
    this.color,
    this.size = 24.0,
  })  : assetPath = null,
        super(key: key);

  // Constructor for Custom Asset Icons
  const AppIcon.asset(
    this.assetPath, {
    Key? key,
    this.color,
    this.size = 24.0,
  })  : iconData = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (iconData != null) {
      return Icon(
        iconData,
        color: color,
        size: size,
      );
    } else if (assetPath != null) {
      // Handles AssetImage for .png/.jpg. (If using SVG, use flutter_svg here)
      return ImageIcon(
        AssetImage(assetPath!),
        color: color,
        size: size,
      );
    }
    
    // Fallback if neither is provided
    return SizedBox(
      width: size,
      height: size,
      child: Icon(Icons.error_outline, size: size, color: Colors.red),
    );
  }
}
