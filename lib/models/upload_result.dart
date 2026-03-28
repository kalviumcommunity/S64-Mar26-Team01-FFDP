/// Represents the status of an upload operation.
enum UploadStatus {
  /// Upload completed successfully.
  success,

  /// Upload failed with an error.
  failed,

  /// Upload was cancelled by user.
  cancelled,

  /// Upload is in progress (used for progress updates).
  inProgress,
}

/// Exception types for storage operations.
enum StorageExceptionType {
  /// File is null or doesn't exist.
  fileNotFound,

  /// File exceeds maximum allowed size.
  fileTooLarge,

  /// File format not supported.
  invalidFormat,

  /// User cancelled the operation.
  cancelled,

  /// Network connection failed.
  networkError,

  /// Firebase Storage operation failed.
  storageError,

  /// Permission denied (storage rules or platform).
  permissionDenied,

  /// Upload was cancelled while in progress.
  uploadCancelled,

  /// Unknown error occurred.
  unknown,
}

/// Custom exception for Firebase Storage operations.
class StorageException implements Exception {
  final StorageExceptionType type;
  final String message;
  final String? originalError;

  const StorageException({
    required this.type,
    required this.message,
    this.originalError,
  });

  factory StorageException.fromError(StorageExceptionType type, Object error) {
    String message;
    switch (type) {
      case StorageExceptionType.fileNotFound:
        message = 'Selected file not found';
      case StorageExceptionType.fileTooLarge:
        message = 'File size exceeds the limit';
      case StorageExceptionType.invalidFormat:
        message = 'File format not supported';
      case StorageExceptionType.cancelled:
        message = 'Operation was cancelled';
      case StorageExceptionType.networkError:
        message = 'Network connection failed';
      case StorageExceptionType.storageError:
        message = 'Storage operation failed';
      case StorageExceptionType.permissionDenied:
        message = 'Permission denied';
      case StorageExceptionType.uploadCancelled:
        message = 'Upload was cancelled';
      case StorageExceptionType.unknown:
        message = 'An unknown error occurred';
    }
    return StorageException(
      type: type,
      message: message,
      originalError: error.toString(),
    );
  }

  @override
  String toString() => 'StorageException($type): $message';
}

/// Result of a storage upload operation.
class UploadResult {
  /// The status of the upload.
  final UploadStatus status;

  /// The download URL of the uploaded file (only if successful).
  final String? downloadUrl;

  /// The storage path where the file was uploaded.
  final String? storagePath;

  /// Error information if the upload failed.
  final StorageException? error;

  /// Upload progress from 0.0 to 1.0 (only for inProgress status).
  final double progress;

  const UploadResult({
    required this.status,
    this.downloadUrl,
    this.storagePath,
    this.error,
    this.progress = 0.0,
  });

  /// Creates a successful upload result.
  const UploadResult.success({
    required String downloadUrl,
    required String storagePath,
  })  : status = UploadStatus.success,
        downloadUrl = downloadUrl,
        storagePath = storagePath,
        error = null,
        progress = 1.0;

  /// Creates a failed upload result.
  const UploadResult.failure({
    required StorageException error,
  })  : status = UploadStatus.failed,
        downloadUrl = null,
        storagePath = null,
        error = error,
        progress = 0.0;

  /// Creates a cancelled upload result.
  const UploadResult.cancelled()
      : status = UploadStatus.cancelled,
        downloadUrl = null,
        storagePath = null,
        error = null,
        progress = 0.0;

  /// Creates an in-progress upload result with progress update.
  const UploadResult.progress({
    required double progress,
  })  : status = UploadStatus.inProgress,
        downloadUrl = null,
        storagePath = null,
        error = null,
        progress = progress;

  /// Whether the upload was successful.
  bool get isSuccess => status == UploadStatus.success;

  /// Whether the upload is in progress.
  bool get isInProgress => status == UploadStatus.inProgress;

  /// Whether the upload failed.
  bool get isFailed => status == UploadStatus.failed;

  /// Whether the upload was cancelled.
  bool get isCancelled => status == UploadStatus.cancelled;

  @override
  String toString() {
    if (status == UploadStatus.success) {
      return 'UploadResult.success(url: $downloadUrl)';
    } else if (status == UploadStatus.failed) {
      return 'UploadResult.failed(error: $error)';
    } else if (status == UploadStatus.cancelled) {
      return 'UploadResult.cancelled()';
    } else {
      return 'UploadResult.progress(${(progress * 100).toStringAsFixed(1)}%)';
    }
  }
}
