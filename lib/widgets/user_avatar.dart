import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String fallbackInitials;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 40.0,
    required this.fallbackInitials,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final effectiveTextColor = theme.colorScheme.onPrimaryContainer;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveBackgroundColor,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildFallback(effectiveTextColor),
                errorWidget: (context, url, error) => _buildFallback(effectiveTextColor),
              )
            : _buildFallback(effectiveTextColor),
      ),
    );
  }

  Widget _buildFallback(Color textColor) {
    return Center(
      child: Text(
        fallbackInitials.toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
