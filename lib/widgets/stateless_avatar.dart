import 'package:flutter/material.dart';

/// CHOICE: StatelessWidget
/// RATIONALE: This widget is a pure presentational component. It takes data 
/// (imageUrl and size) and renders it. Since the data is passed from a 
/// parent and doesn't change internally, a StatelessWidget is the most 
/// performance-efficient choice.
class StatelessAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String fallbackInitials;

  const StatelessAvatar({
    super.key,
    this.imageUrl,
    this.size = 40.0,
    required this.fallbackInitials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                fallbackInitials.toUpperCase(),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            )
          : null,
    );
  }
}
