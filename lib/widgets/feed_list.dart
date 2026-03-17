import 'package:flutter/material.dart';
import 'layout_components.dart';
import 'stateless_avatar.dart';

/// A component displaying a scrollable list of mockup feed posts.
/// Uses ListView.builder for lazy loading, rendering items only when 
/// they scroll into the viewport, which is crucial for performance.
class FeedList extends StatelessWidget {
  final int itemCount;

  const FeedList({
    Key? key,
    this.itemCount = 20, // Default to generating 20 dummy posts
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Ensure the padding doesn't get cut off at the bottom
      padding: const EdgeInsets.only(bottom: 24, top: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _buildFeedItem(context, index);
      },
    );
  }

  // Helper method to build a single feed post item
  Widget _buildFeedItem(BuildContext context, int index) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatelessAvatar(
                fallbackInitials: 'U$index',
                size: 36,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User $index',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '2 hours ago',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This is a sample post for item #$index. It demonstrates how a basic '
            'feed structure is formulated using reusable layout components '
            'inside a performant ListView.builder.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // Placeholder for an image or multimedia content
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}
