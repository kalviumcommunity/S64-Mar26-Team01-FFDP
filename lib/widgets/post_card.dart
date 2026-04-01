import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  final String userName;
  final String? userImageUrl;
  final String timestamp;
  final String content;
  final String? postImageUrl;
  final int likesCount;
  final int commentsCount;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;

  const PostCard({
    super.key,
    required this.userName,
    this.userImageUrl,
    required this.timestamp,
    required this.content,
    this.postImageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.onLikePressed,
    this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Header
            Row(
              children: [
                UserAvatar(
                  imageUrl: userImageUrl,
                  fallbackInitials: userName.isNotEmpty ? userName[0] : '?',
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timestamp,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Post Content
            Text(
              content,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            // Post Image
            if (postImageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: postImageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Action Buttons
            Divider(color: theme.colorScheme.outlineVariant),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: likesCount > 0 ? '$likesCount' : 'Like',
                  onPressed: onLikePressed,
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: commentsCount > 0 ? '$commentsCount' : 'Comment',
                  onPressed: onCommentPressed,
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
      label: Text(
        label,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
