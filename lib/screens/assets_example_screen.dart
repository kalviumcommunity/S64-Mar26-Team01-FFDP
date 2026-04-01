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
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Local Image Asset',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Example of local image loading using the utility widget
            // Will show error fallback safely since placeholder.png doesn't exist yet
            AppImage(
              assetPath: AppAssets.placeholderImage,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),

            SizedBox(height: 24),

            Text(
              '2. Material Icon (AppIcon)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            AppIcon.material(
              Icons.settings,
              size: 40,
              color: Colors.blue,
            ),

            SizedBox(height: 24),

            Text(
              '3. Asset Icon (AppIcon)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Will show fallback since errorIcon doesn't exist yet
            AppIcon.asset(
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
