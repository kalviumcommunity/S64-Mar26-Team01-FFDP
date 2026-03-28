import 'package:flutter/material.dart';

/// Reusable widget for displaying upload progress.
///
/// Shows a progress bar with percentage and optional cancel button.
class UploadProgressWidget extends StatelessWidget {
  /// Current upload progress from 0.0 to 1.0.
  final double progress;

  /// Optional file name to display.
  final String? fileName;

  /// Whether the cancel button should be shown.
  final bool showCancelButton;

  /// Callback when cancel button is pressed.
  final VoidCallback? onCancel;

  /// Optional custom label (defaults to "Uploading...")
  final String? label;

  const UploadProgressWidget({
    super.key,
    required this.progress,
    this.fileName,
    this.showCancelButton = true,
    this.onCancel,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentText = '${(progress * 100).toStringAsFixed(0)}%';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label ?? 'Uploading...',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              percentText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),

        // File name and cancel button
        if (fileName != null || showCancelButton) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (fileName != null)
                Expanded(
                  child: Text(
                    _truncateFileName(fileName!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              if (showCancelButton && onCancel != null)
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _truncateFileName(String name) {
    if (name.length <= 30) return name;
    final ext = name.split('.').last;
    final baseName = name.substring(0, name.length - ext.length - 1);
    final truncatedBase = baseName.length > 20
        ? '${baseName.substring(0, 17)}...'
        : baseName;
    return '$truncatedBase.$ext';
  }
}

/// A simple loading overlay for upload operations.
class UploadLoadingOverlay extends StatelessWidget {
  final double progress;
  final String? message;

  const UploadLoadingOverlay({
    super.key,
    required this.progress,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message ?? 'Uploading...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
