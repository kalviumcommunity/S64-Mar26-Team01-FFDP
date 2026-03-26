import 'package:flutter/material.dart';
import '../utils/app_assets.dart';
import '../widgets/app_image.dart';
import '../widgets/app_icon.dart';

class AssetsExampleScreen extends StatelessWidget {
  const AssetsExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets Management Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Local Image Asset',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Example of local image loading using the utility widget
            // Will show error fallback safely since placeholder.png doesn't exist yet
            const AppImage(
              assetPath: AppAssets.placeholderImage,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              '2. Material Icon (AppIcon)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const AppIcon.material(
              Icons.settings,
              size: 40,
              color: Colors.blue,
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              '3. Asset Icon (AppIcon)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Will show fallback since errorIcon doesn't exist yet
            const AppIcon.asset(
              AppAssets.errorIcon,
              size: 40,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
