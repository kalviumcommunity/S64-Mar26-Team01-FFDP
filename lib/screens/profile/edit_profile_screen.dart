import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../utils/media_picker_util.dart';
import '../../widgets/upload_progress_widget.dart';

/// Screen for editing user profile, including avatar change.
///
/// Demonstrates:
/// - Safe image selection with MediaPickerUtil
/// - Upload progress tracking
/// - Cancel support
/// - Error handling with user-friendly messages
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();

  // Upload state
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;

  // Selected image
  File? _selectedImage;
  String? _newAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final user = AuthService().currentUser;
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// Pick image using MediaPickerUtil (safe cancel handling).
  Future<void> _pickImage() async {
    // Reset error state
    setState(() => _uploadError = null);

    // Use MediaPickerUtil for safe file selection
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

  /// Upload avatar with progress tracking.
  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    final user = AuthService().currentUser;
    if (user == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadError = null;
    });

    final uploadId = 'edit_profile_avatar_${DateTime.now().millisecondsSinceEpoch}';

    final result = await StorageService.instance.uploadUserAvatar(
      userId: user.uid,
      imageFile: _selectedImage!,
      uploadId: uploadId,
      onProgress: (progress) {
        if (mounted) {
          setState(() => _uploadProgress = progress);
        }
      },
    );

    if (!mounted) return;

    setState(() => _isUploading = false);

    if (result.isSuccess) {
      setState(() {
        _newAvatarUrl = result.downloadUrl;
        _selectedImage = null; // Clear selected image on success
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // TODO: Optionally update AuthService/Firestore with new avatar URL
    } else {
      setState(() => _uploadError = result.error?.message ?? 'Upload failed');
    }
  }

  /// Cancel the current upload.
  Future<void> _cancelUpload() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    final uploadId = 'edit_profile_avatar_${DateTime.now().millisecondsSinceEpoch}';
    final cancelled = await StorageService.instance.cancelUpload(uploadId);

    if (cancelled && mounted) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload cancelled'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService().currentUser;

    // Determine avatar image source
    ImageProvider? avatarImage;
    if (_newAvatarUrl != null) {
      avatarImage = CachedNetworkImageProvider(_newAvatarUrl!);
    } else if (user?.photoURL != null) {
      avatarImage = CachedNetworkImageProvider(user!.photoURL!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isUploading)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelUpload,
              tooltip: 'Cancel upload',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar section
              Center(
                child: Stack(
                  children: [
                    // Avatar display
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : avatarImage,
                      child: _selectedImage == null && avatarImage == null
                          ? Text(
                              (user?.displayName?.isNotEmpty == true
                                      ? user!.displayName![0]
                                      : user?.email?[0] ?? 'U')
                                  .toUpperCase(),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),

                    // Upload progress overlay
                    if (_isUploading)
                      Positioned.fill(
                        child: CircleAvatar(
                          backgroundColor: Colors.black38,
                          child: CircularProgressIndicator(
                            value: _uploadProgress,
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),

                    // Camera overlay button
                    if (!_isUploading)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.primary,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 24),

              // Upload progress widget
              if (_isUploading) ...[
                UploadProgressWidget(
                  progress: _uploadProgress,
                  fileName: _selectedImage?.path.split('/').last,
                  onCancel: _cancelUpload,
                ),
                const SizedBox(height: 24),
              ],

              // Form fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Display name
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Bio
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: const Icon(Icons.info_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      maxLength: 160,
                    ),

                    const SizedBox(height: 24),

                    // Upload button (only show if image selected)
                    if (_selectedImage != null && !_isUploading)
                      FilledButton.icon(
                        onPressed: _uploadAvatar,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload New Avatar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Save button
                    FilledButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                // TODO: Save profile changes
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile saved!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            },
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
