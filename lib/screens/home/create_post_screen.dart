import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../utils/media_picker_util.dart';
import '../../widgets/upload_progress_widget.dart';

/// Screen for creating a new post with optional image attachment.
///
/// Demonstrates:
/// - Complete upload flow with validation
/// - Progress tracking for image uploads
/// - Error handling for all failure scenarios
/// - Clean separation between UI and upload logic
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  // Upload state
  bool _isUploading = false;
  bool _isPosting = false;
  double _uploadProgress = 0.0;
  String? _uploadError;

  // Selected image
  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// Pick image using MediaPickerUtil (safe cancel handling).
  Future<void> _pickImage() async {
    setState(() => _uploadError = null);

    final File? image = await MediaPickerUtil.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      // User cancelled - this is normal, no error needed
      return;
    }

    // Validate file before attempting upload
    final (isValid, errorMsg) = MediaPickerUtil.validateImage(image);
    if (!isValid) {
      setState(() => _uploadError = errorMsg);
      return;
    }

    setState(() => _selectedImage = image);
  }

  /// Take photo using camera.
  Future<void> _takePhoto() async {
    setState(() => _uploadError = null);

    final File? image = await MediaPickerUtil.pickFromCamera();

    if (image == null) {
      return;
    }

    final (isValid, errorMsg) = MediaPickerUtil.validateImage(image);
    if (!isValid) {
      setState(() => _uploadError = errorMsg);
      return;
    }

    setState(() => _selectedImage = image);
  }

  /// Remove selected image.
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
      _uploadError = null;
    });
  }

  /// Upload the selected image to Firebase Storage.
  ///
  /// Returns the download URL on success, null on failure.
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    final user = AuthService().currentUser;
    if (user == null) return null;

    // Generate a unique postId for the upload path
    final postId = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
    final uploadId = 'create_post_$postId';

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadError = null;
    });

    final result = await StorageService.instance.uploadPostImage(
      postId: postId,
      imageFile: _selectedImage!,
      uploadId: uploadId,
      onProgress: (progress) {
        if (mounted) {
          setState(() => _uploadProgress = progress);
        }
      },
    );

    if (!mounted) return null;

    setState(() => _isUploading = false);

    if (result.isSuccess) {
      setState(() => _uploadedImageUrl = result.downloadUrl);
      return result.downloadUrl;
    } else {
      setState(() => _uploadError = result.error?.message ?? 'Upload failed');
      return null;
    }
  }

  /// Submit the post with optional image.
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    // If there's an image selected but not yet uploaded, upload it first
    if (_selectedImage != null && _uploadedImageUrl == null && !_isUploading) {
      // Upload image before posting
      setState(() => _isPosting = true);

      final imageUrl = await _uploadImage();

      if (!mounted) return;

      if (imageUrl == null) {
        setState(() => _isPosting = false);
        return; // Error already set in _uploadImage
      }
    }

    // At this point, either:
    // - No image was selected, OR
    // - Image was already uploaded and _uploadedImageUrl is set

    setState(() => _isPosting = true);

    try {
      // TODO: Save post to Firestore using _uploadedImageUrl
      // For now, just show success

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Post button
          TextButton(
            onPressed: _isUploading || _isPosting ? null : _submitPost,
            child: _isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Content text field
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  maxLines: 5,
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write something';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Image attachment section
                if (_selectedImage != null) ...[
                  // Image preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.file(
                          _selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        // Remove button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton.filled(
                            onPressed: _isUploading ? null : _removeImage,
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        // Upload progress overlay
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black38,
                              child: Center(
                                child: UploadProgressWidget(
                                  progress: _uploadProgress,
                                  showCancelButton: false,
                                ),
                              ),
                            ),
                          ),

                        // Uploaded badge
                        if (_uploadedImageUrl != null && !_isUploading)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Uploaded',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],

                // Error message
                if (_uploadError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _uploadError!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Media attachment buttons
                Row(
                  children: [
                    // Gallery button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _isUploading || _isPosting ? null : _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Camera button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _isUploading || _isPosting ? null : _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit button
                FilledButton.icon(
                  onPressed: _isUploading || _isPosting ? null : _submitPost,
                  icon: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isPosting ? 'Posting...' : 'Post'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                // Help text
                if (_selectedImage == null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Add an image to make your post more engaging!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
