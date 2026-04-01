import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

/// Supported image formats for upload.
const List<String> supportedImageExtensions = [
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
  'heic',
  'heif',
];

/// Default maximum file size in megabytes.
const int defaultMaxFileSizeMB = 10;

/// Utility class for safe media/file selection.
class MediaPickerUtil {
  static final ImagePicker _picker = ImagePicker();

  /// Pick a single image from gallery or camera.
  ///
  /// Returns `null` if:
  /// - User cancels the selection
  /// - No image is selected
  /// - Platform returns null
  ///
  /// Returns a [File] if successful.
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) {
        debugPrint('MediaPickerUtil: User cancelled or no file selected');
        return null;
      }

      final file = File(pickedFile.path);

      // Verify file exists and is readable
      if (!await file.exists()) {
        debugPrint('MediaPickerUtil: Picked file does not exist');
        return null;
      }

      return file;
    } catch (e) {
      debugPrint('MediaPickerUtil: Error picking image — $e');
      return null;
    }
  }

  /// Pick multiple images (for future use).
  ///
  /// Returns empty list if user cancels or no images selected.
  static Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFiles.isEmpty) {
        debugPrint('MediaPickerUtil: User cancelled or no files selected');
        return [];
      }

      final files = <File>[];
      for (final xFile in pickedFiles) {
        final file = File(xFile.path);
        if (await file.exists()) {
          files.add(file);
        }
      }

      return files;
    } catch (e) {
      debugPrint('MediaPickerUtil: Error picking multiple images — $e');
      return [];
    }
  }

  /// Pick image from camera (useful for quick captures).
  static Future<File?> pickFromCamera() async {
    return pickImage(source: ImageSource.camera);
  }

  /// Validate an image file before upload.
  ///
  /// Returns `(isValid, errorMessage)` tuple.
  /// `isValid` is `true` if file passes all checks.
  /// `errorMessage` is non-null if validation failed.
  static (bool, String?) validateImage(
    File file, {
    int maxSizeMB = defaultMaxFileSizeMB,
  }) {
    // Check if file exists
    if (!file.existsSync()) {
      return (false, 'File does not exist');
    }

    // Check file size
    final sizeInBytes = file.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);

    if (sizeInMB > maxSizeMB) {
      return (
        false,
        'File size (${sizeInMB.toStringAsFixed(1)} MB) exceeds $maxSizeMB MB limit'
      );
    }

    // Check file extension
    final path = file.path.toLowerCase();
    final fileName =
        path.contains('/') ? path.split('/').last : path.split('\\').last;
    final extension = fileName.contains('.') ? fileName.split('.').last : '';

    if (!supportedImageExtensions.contains(extension)) {
      return (
        false,
        'Format .$extension not supported. Use: ${supportedImageExtensions.join(", ")}'
      );
    }

    // Check for valid path
    if (path.isEmpty || !path.contains('/')) {
      return (false, 'Invalid file path');
    }

    return (true, null);
  }

  /// Get file extension from path (lowercase, without dot).
  static String getExtension(String filePath) {
    final fileName = filePath.contains('/')
        ? filePath.split('/').last
        : filePath.split('\\').last;
    final parts = fileName.toLowerCase().split('.');
    return parts.length > 1 ? parts.last : '';
  }

  /// Check if a file extension is a supported image format.
  static bool isSupportedImageFormat(String extension) {
    return supportedImageExtensions
        .contains(extension.toLowerCase().replaceAll('.', ''));
  }
}
