import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/animations/animated_like_button.dart';
import '../../widgets/animations/custom_loading_indicator.dart';

class AnimationDemoScreen extends StatelessWidget {
  const AnimationDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animations & Transitions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Like Animation Example
            _buildSection(
              title: '1. Animated Like Button',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AnimatedLikeButton(
                    size: 48,
                  ),
                  const SizedBox(width: 32),
                  AnimatedLikeButton(
                    size: 48,
                    initialIsLiked: true,
                    onToggle: (liked) {
                      debugPrint('Liked status changed: $liked');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Loading Indicators Example
            _buildSection(
              title: '2. Loading Animations',
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomLoadingIndicator(size: 30, color: Colors.blue),
                      CustomLoadingIndicator(size: 50, color: Colors.red),
                      CustomLoadingIndicator(strokeWidth: 6),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const ShimmerLoadingBox(width: 60, height: 60),
                      ShimmerLoadingBox(
                        width: 120,
                        height: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. Page Transitions Example
            _buildSection(
              title: '3. Page Transitions',
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Slide Transition Route'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransitions.slide(const _DummyDestinationScreen(
                          title: 'Slided Screen',
                        )),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.opacity),
                    label: const Text('Fade Transition Route'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransitions.fade(const _DummyDestinationScreen(
                          title: 'Faded Screen',
                        )),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _DummyDestinationScreen extends StatelessWidget {
  final String title;
  const _DummyDestinationScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to $title!'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
