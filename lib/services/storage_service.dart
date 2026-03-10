import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Service class for Firebase Storage operations
class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  /// Upload user avatar image
  Future<String> uploadUserAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Compress image before upload
      final compressedImage = await _compressImage(imageFile);

      final ref = _firebaseStorage.ref().child('avatars/$userId/profile.jpg');
      await ref.putFile(
        compressedImage,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload avatar: $e';
    }
  }

  /// Upload post image
  Future<String> uploadPostImage({
    required String postId,
    required File imageFile,
  }) async {
    try {
      final compressedImage = await _compressImage(imageFile);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = _firebaseStorage
          .ref()
          .child('posts/$postId/$fileName.jpg');
      await ref.putFile(
        compressedImage,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload post image: $e';
    }
  }

  /// Upload event banner image
  Future<String> uploadEventImage({
    required String eventId,
    required File imageFile,
  }) async {
    try {
      final compressedImage = await _compressImage(imageFile);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = _firebaseStorage
          .ref()
          .child('events/$eventId/$fileName.jpg');
      await ref.putFile(
        compressedImage,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload event image: $e';
    }
  }

  /// Upload chat media
  Future<String> uploadChatMedia({
    required String chatId,
    required File mediaFile,
  }) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final extension = mediaFile.path.split('.').last;

      final ref = _firebaseStorage
          .ref()
          .child('chat_media/$chatId/$fileName.$extension');
      await ref.putFile(mediaFile);

      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload chat media: $e';
    }
  }

  /// Delete a file from storage
  Future<void> deleteFile(String filePath) async {
    try {
      await _firebaseStorage.ref(filePath).delete();
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }

  /// Delete user avatar
  Future<void> deleteUserAvatar(String userId) async {
    try {
      final ref = _firebaseStorage.ref().child('avatars/$userId/profile.jpg');
      await ref.delete();
    } catch (e) {
      // Silently fail if avatar doesn't exist
      print('Avatar not found: $e');
    }
  }

  /// Compress image file to reduce size
  Future<File> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = '${splitted}_out${filePath.substring(lastIndex)}';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 80,
        minHeight: 1024,
        minWidth: 1024,
      );

      return File(result?.path ?? file.path);
    } catch (e) {
      print('Image compression failed: $e');
      return file; // Return original if compression fails
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadURL(String filePath) async {
    try {
      return await _firebaseStorage.ref(filePath).getDownloadURL();
    } catch (e) {
      throw 'Failed to get download URL: $e';
    }
  }

  /// Check if user has storage quota remaining
  Future<bool> hasStorageQuota() async {
    try {
      // Firebase Storage doesn't have direct quota checking,
      // so we'll consider it always available unless an error occurs
      return true;
    } catch (e) {
      return false;
    }
  }
}
