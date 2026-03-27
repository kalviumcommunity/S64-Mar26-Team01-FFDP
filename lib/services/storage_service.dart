import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/upload_result.dart';

/// Service class for Firebase Storage operations.
///
/// Provides upload, download, delete, and URL retrieval operations
/// with progress tracking and cancellation support.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;

  StorageService._internal();

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Active upload tasks for cancellation support.
  // Key: uploadId, Value: UploadTask
  final Map<String, UploadTask> _activeTasks = {};

  // Supported image MIME types.
  static const Map<String, String> _imageMimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'heic': 'image/heic',
    'heif': 'image/heif',
  };

  /// Upload user avatar image.
  ///
  /// Compresses the image before upload and tracks progress.
  ///
  /// [userId] - The user's unique ID.
  /// [imageFile] - The image file to upload.
  /// [onProgress] - Optional callback for progress updates (0.0 to 1.0).
  /// [uploadId] - Optional unique ID for this upload (for cancellation).
  ///               Defaults to 'avatar_{userId}'.
  Future<UploadResult> uploadUserAvatar({
    required String userId,
    required File imageFile,
    void Function(double progress)? onProgress,
    String? uploadId,
  }) async {
    final id = uploadId ?? 'avatar_$userId';

    try {
      // Validate file
      final validation = _validateImageFile(imageFile);
      if (!validation.$1) {
        return UploadResult.failure(
          error: StorageException(
            type: StorageExceptionType.invalidFormat,
            message: validation.$2!,
          ),
        );
      }

      // Compress image before upload
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        return UploadResult.failure(
          error: const StorageException(
            type: StorageExceptionType.storageError,
            message: 'Image compression failed',
          ),
        );
      }

      final ref = _firebaseStorage.ref().child('avatars/$userId/profile.jpg');
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'max-age=31536000', // 1 year cache
      );

      // Start upload with progress tracking
      final task = ref.putFile(compressedImage, metadata);
      _activeTasks[id] = task;

      // Track progress
      await _trackProgress(task, onProgress);

      // Wait for completion and get URL
      await task;
      final downloadUrl = await ref.getDownloadURL();

      _activeTasks.remove(id);
      _cleanupTempFile(compressedImage, imageFile);

      return UploadResult.success(
        downloadUrl: downloadUrl,
        storagePath: 'avatars/$userId/profile.jpg',
      );
    } on FirebaseException catch (e) {
      _activeTasks.remove(id);
      return UploadResult.failure(
        error: StorageException.fromError(
          _mapFirebaseError(e),
          e,
        ),
      );
    } catch (e) {
      _activeTasks.remove(id);
      return UploadResult.failure(
        error: StorageException.fromError(
          StorageExceptionType.unknown,
          e,
        ),
      );
    }
  }

  /// Upload post image.
  ///
  /// [postId] - The post's unique ID.
  /// [imageFile] - The image file to upload.
  /// [onProgress] - Optional callback for progress updates.
  /// [uploadId] - Optional unique ID for this upload.
  /// [fileExtension] - Optional file extension (defaults to 'jpg').
  Future<UploadResult> uploadPostImage({
    required String postId,
    required File imageFile,
    void Function(double progress)? onProgress,
    String? uploadId,
    String? fileExtension,
  }) async {
    final id = uploadId ?? 'post_$postId';

    try {
      // Validate file
      final validation = _validateImageFile(imageFile);
      if (!validation.$1) {
        return UploadResult.failure(
          error: StorageException(
            type: StorageExceptionType.invalidFormat,
            message: validation.$2!,
          ),
        );
      }

      // Compress image before upload
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        return UploadResult.failure(
          error: const StorageException(
            type: StorageExceptionType.storageError,
            message: 'Image compression failed',
          ),
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = fileExtension ?? _getExtension(imageFile.path);
      final ref = _firebaseStorage.ref().child('posts/$postId/$timestamp.$ext');
      final metadata = SettableMetadata(
        contentType: _imageMimeTypes[ext] ?? 'image/jpeg',
      );

      final task = ref.putFile(compressedImage, metadata);
      _activeTasks[id] = task;

      await _trackProgress(task, onProgress);

      await task;
      final downloadUrl = await ref.getDownloadURL();

      _activeTasks.remove(id);
      _cleanupTempFile(compressedImage, imageFile);

      return UploadResult.success(
        downloadUrl: downloadUrl,
        storagePath: 'posts/$postId/$timestamp.$ext',
      );
    } on FirebaseException catch (e) {
      _activeTasks.remove(id);
      return UploadResult.failure(
        error: StorageException.fromError(_mapFirebaseError(e), e),
      );
    } catch (e) {
      _activeTasks.remove(id);
      return UploadResult.failure(
        error: StorageException.fromError(StorageExceptionType.unknown, e),
      );
    }
  }

  /// Upload event banner image.
  ///
  /// [eventId] - The event's unique ID.
  /// [imageFile] - The image file to upload.
  /// [onProgress] - Optional callback for progress updates.
  /// [uploadId] - Optional unique ID for this upload.
  Future<UploadResult> uploadEventImage({
    required String eventId,
    required File imageFile,
    void Function(double progress)? onProgress,
    String? uploadId,
  }) async {
    final id = uploadId ?? 'event_$eventId';

    try {
      final validation = _validateImageFile(imageFile);
      if (!validation.$1) {
        return UploadResult.failure(
          error: StorageException(
            type: StorageExceptionType.invalidFormat,
            message: validation.$2!,
          ),
        );
      }

      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        return UploadResult.failure(
          error: const StorageException(
            type: StorageExceptionType.storageError,
            message: 'Image compression failed',
          ),
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = _getExtension(imageFile.path);
      final ref = _firebaseStorage.ref().child('events/$eventId/$timestamp.$ext');
      final metadata = SettableMetadata(
        contentType: _imageMimeTypes[ext] ?? 'image/jpeg',
      );

      final task = ref.putFile(compressedImage, metadata);
      _activeTasks[id] = task;

      await _trackProgress(task, onProgress);

      await task;
      final downloadUrl = await ref.getDownloadURL();

      _activeTasks.remove(id);
      _cleanupTempFile(compressedImage, imageFile);

      return UploadResult.success(
        downloadUrl: downloadUrl,
        storagePath: 'events/$eventId/$timestamp.$ext',
      );
    } on FirebaseException catch (e) {
      _activeTasks.remove(id);
      return UploadResult.failure(
        error: StorageException.fromError(_mapFirebaseError(e), e),
      );
    } catch (e) {
      _activeTasks.remove(id);
      return UploadResult.failure(
        error: StorageException.fromError(StorageExceptionType.unknown, e),
      );
    }
  }

  /// Upload chat media (image or other file).
  ///
  /// [chatId] - The chat's unique ID.
  /// [mediaFile] - The file to upload.
  /// [onProgress] - Optional callback for progress updates.
  /// [uploadId] - Optional unique ID for this upload.
  ///
  /// Note: This method does NOT compress non-image files.
  /// Images are compressed to save bandwidth.
  Future<UploadResult> uploadChatMedia({
    required String chatId,
    required File mediaFile,
    void Function(double progress)? onProgress,
    String? uploadId,
  }) async {
    final id = uploadId ?? 'chat_$chatId';

    try {
      // For images, validate; for other files, just check existence
      final isImage = _isImageFile(mediaFile.path);
      if (isImage) {
        final validation = _validateImageFile(mediaFile);
        if (!validation.$1) {
          return UploadResult.failure(
            error: StorageException(
              type: StorageExceptionType.invalidFormat,
              message: validation.$2!,
            ),
          );
        }
      }

      // Only compress images
      File? fileToUpload = mediaFile;
      if (isImage) {
        final compressed = await _compressImage(mediaFile);
        if (compressed != null) {
          fileToUpload = compressed;
        }
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = _getExtension(mediaFile.path);
      final mimeType = _imageMimeTypes[ext] ?? 'application/octet-stream';
      final ref = _firebaseStorage.ref().child('chat_media/$chatId/$timestamp.$ext');
      final metadata = SettableMetadata(contentType: mimeType);

      final task = ref.putFile(fileToUpload, metadata);
      _activeTasks[id] = task;

      await _trackProgress(task, onProgress);

      await task;
      final downloadUrl = await ref.getDownloadURL();

      _activeTasks.remove(id);
      if (fileToUpload != mediaFile) {
        _cleanupTempFile(fileToUpload, mediaFile);
      }

      return UploadResult.success(
        downloadUrl: downloadUrl,
        storagePath: 'chat_media/$chatId/$timestamp.$ext',
      );
    } on FirebaseException catch (e) {
      _activeTasks.remove(id);
      return UploadResult.failure(
        error: StorageException.fromError(_mapFirebaseError(e), e),
      );
    } catch (e) {
      _activeTasks.remove(id);
      return UploadResult.failure(
        error: StorageException.fromError(StorageExceptionType.unknown, e),
      );
    }
  }

  /// Cancel an active upload by its ID.
  ///
  /// Returns `true` if the upload was cancelled successfully.
  /// Returns `false` if no active upload with that ID was found.
  Future<bool> cancelUpload(String uploadId) async {
    final task = _activeTasks[uploadId];
    if (task == null) {
      debugPrint('StorageService: No active upload found with ID: $uploadId');
      return false;
    }

    await task.cancel();
    _activeTasks.remove(uploadId);
    debugPrint('StorageService: Upload cancelled: $uploadId');
    return true;
  }

  /// Check if an upload is currently in progress.
  bool isUploadActive(String uploadId) {
    return _activeTasks.containsKey(uploadId);
  }

  /// Delete a file from storage by its full path.
  ///
  /// [filePath] - Full path relative to storage root (e.g., 'avatars/user123/profile.jpg').
  Future<void> deleteFile(String filePath) async {
    try {
      await _firebaseStorage.ref(filePath).delete();
      debugPrint('StorageService: Deleted file: $filePath');
    } on FirebaseException catch (e) {
      // Handle "file not found" gracefully — it's already deleted
      // Storage uses 'object-not-found' code for missing files
      if (e.code == 'object-not-found' || e.code == '404') {
        debugPrint('StorageService: File not found (already deleted?): $filePath');
        return;
      }
      rethrow;
    }
  }

  /// Delete user avatar.
  ///
  /// Silently fails if avatar doesn't exist (idempotent operation).
  Future<void> deleteUserAvatar(String userId) async {
    try {
      final ref = _firebaseStorage.ref().child('avatars/$userId/profile.jpg');
      await ref.delete();
      debugPrint('StorageService: Deleted avatar for user: $userId');
    } on FirebaseException catch (e) {
      // 404/object-not-found means already deleted — that's fine
      if (e.code != 'object-not-found' && e.code != '404') {
        debugPrint('StorageService: Failed to delete avatar: $e');
      }
    }
  }

  /// Get download URL for a file.
  ///
  /// [filePath] - Full path relative to storage root.
  Future<String> getDownloadURL(String filePath) async {
    try {
      return await _firebaseStorage.ref(filePath).getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException.fromError(_mapFirebaseError(e), e);
    }
  }

  /// Validate an image file before upload.
  ///
  /// Returns `(isValid, errorMessage)` tuple.
  static (bool, String?) _validateImageFile(File file) {
    // Check existence
    if (!file.existsSync()) {
      return (false, 'File does not exist');
    }

    // Check size (max 10MB)
    final sizeInBytes = file.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    if (sizeInMB > 10) {
      return (false, 'File size (${sizeInMB.toStringAsFixed(1)} MB) exceeds 10 MB limit');
    }

    // Check extension
    final ext = _getExtension(file.path);
    if (!supportedImageExtensions.contains(ext)) {
      return (false, 'Format .$ext not supported');
    }

    return (true, null);
  }

  /// Get file extension from path (lowercase, without dot).
  static String _getExtension(String filePath) {
    final parts = filePath.toLowerCase().split('.');
    return parts.length > 1 ? parts.last : '';
  }

  /// Check if a file is an image based on extension.
  static bool _isImageFile(String filePath) {
    final ext = _getExtension(filePath);
    return supportedImageExtensions.contains(ext);
  }

  /// Track upload progress and call callback.
  Future<void> _trackProgress(
    UploadTask task,
    void Function(double progress)? callback,
  ) async {
    if (callback == null) return;

    try {
      await for (final snapshot in task.snapshotEvents) {
        if (snapshot.state == TaskState.canceled) {
          break;
        }
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        callback(progress.clamp(0.0, 1.0));
      }
    } catch (e) {
      // Stream may error if cancelled — that's expected
      debugPrint('StorageService: Progress tracking ended: $e');
    }
  }

  /// Compress image file to reduce size.
  ///
  /// Returns the compressed file, or `null` if compression fails.
  Future<File?> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastDotIndex = filePath.lastIndexOf('.');
      if (lastDotIndex == -1) {
        return file; // No extension found
      }

      final splitted = filePath.substring(0, lastDotIndex);
      final extension = filePath.substring(lastDotIndex);
      final outPath = '${splitted}_compressed$extension';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 80,
        minHeight: 1024,
        minWidth: 1024,
      );

      if (result == null) {
        debugPrint('StorageService: Compression returned null, using original');
        return file;
      }

      final compressedFile = File(result.path);

      // Verify compressed file exists and is smaller
      if (await compressedFile.exists()) {
        final originalSize = await file.length();
        final compressedSize = await compressedFile.length();

        // Only use compressed if it's actually smaller
        if (compressedSize < originalSize) {
          return compressedFile;
        } else {
          debugPrint('StorageService: Compression did not reduce size, using original');
          _cleanupTempFile(compressedFile, file);
          return file;
        }
      }

      return file;
    } catch (e) {
      debugPrint('StorageService: Image compression failed: $e');
      return file; // Fallback to original
    }
  }

  /// Clean up temporary compressed file if it's different from original.
  void _cleanupTempFile(File compressedFile, File originalFile) {
    if (compressedFile.path == originalFile.path) return;

    try {
      if (compressedFile.existsSync()) {
        compressedFile.deleteSync();
      }
    } catch (e) {
      debugPrint('StorageService: Failed to cleanup temp file: $e');
    }
  }

  /// Map Firebase exception to our StorageExceptionType.
  StorageExceptionType _mapFirebaseError(FirebaseException e) {
    final code = e.code;

    switch (code) {
      case 'unauthorized':
      case 'forbidden':
        return StorageExceptionType.permissionDenied;
      case 'object-not-found':
        return StorageExceptionType.fileNotFound;
      case 'canceled':
        return StorageExceptionType.uploadCancelled;
      case 'network-error':
      case 'unknown':
        if (e.message?.contains('network') ?? false) {
          return StorageExceptionType.networkError;
        }
        return StorageExceptionType.storageError;
      default:
        return StorageExceptionType.storageError;
    }
  }
}

// Supported image extensions (re-exported for convenience)
const List<String> supportedImageExtensions = [
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
  'heic',
  'heif',
];
