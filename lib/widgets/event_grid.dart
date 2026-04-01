import 'package:flutter/material.dart';

/// A component displaying a grid of community events.
/// Uses GridView.builder to lazily render grid items, ensuring high
/// performance even with a large dataset.
class EventGrid extends StatelessWidget {
  final int eventCount;

  const EventGrid({
    super.key,
    this.eventCount = 12, // Default to generating 12 dummy events
  });

  @override
  Widget build(BuildContext context) {
    // GridView.builder calculates the exact positions of items based on
    // the SilverGridDelegate configuration before actually building them.
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eventCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        crossAxisSpacing: 16, // Horizontal gap
        mainAxisSpacing: 16, // Vertical gap
        childAspectRatio: 0.8, // Ratio of width to height (taller than wide)
      ),
      itemBuilder: (context, index) {
        return _buildEventCard(context, index);
      },
    );
  }

  // Helper method to build an individual event square
  Widget _buildEventCard(BuildContext context, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expanded allows the placeholder image area to take up remaining height
            Expanded(
              flex: 3,
              child: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Center(
                  child: Icon(
                    Icons.event,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            // Information Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Community Event $index',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                    Text(
                      'Oct ${10 + index}, 2026',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
