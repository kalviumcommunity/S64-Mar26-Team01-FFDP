import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

/// Service class for Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== User Operations ====================

  /// Create or update user document in Firestore
  Future<void> createUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to create user document: $e';
    }
  }

  /// Get user document by UID
  Future<UserModel?> getUserDocument(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user document: $e';
    }
  }

  /// Get user stream for real-time updates
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
      }
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // ==================== Post/Note Operations ====================

  /// Create a new post/note
  Future<String> createPost({
    required String uid,
    required String content,
    required String displayName,
    String? imageUrl,
  }) async {
    try {
      final docRef = await _firestore.collection('posts').add({
        'uid': uid,
        'displayName': displayName,
        'content': content,
        'imageUrl': imageUrl ?? '',
        'likes': 0,
        'comments': 0,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to create post: $e';
    }
  }

  /// Get all posts as a stream with enhanced error handling
  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              // Safely handle potentially malformed documents
              return PostModel.fromFirestore(doc);
            } catch (e) {
              // We can't return null here, so we create a placeholder post
              return PostModel(
                postId: doc.id,
                uid: 'error',
                displayName: 'Error Loading Post',
                content: 'This post could not be loaded due to a data error.',
                likes: 0,
                comments: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                tags: [],
              );
            }
          })
          .toList();
    });
  }

  /// Get posts by user with enhanced error handling
  Stream<List<PostModel>> getUserPostsStream(String uid) {
    return _firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              // Safely handle potentially malformed documents
              return PostModel.fromFirestore(doc);
            } catch (e) {
              // We can't return null here, so we create a placeholder post
              return PostModel(
                postId: doc.id,
                uid: 'error',
                displayName: 'Error Loading Post',
                content: 'This post could not be loaded due to a data error.',
                likes: 0,
                comments: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                tags: [],
              );
            }
          })
          .toList();
    });
  }

  /// Update a post
  Future<void> updatePost({
    required String postId,
    required String content,
  }) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'content': content,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to update post: $e';
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw 'Failed to delete post: $e';
    }
  }

  /// Add like to a post
  Future<void> likePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to like post: $e';
    }
  }

  /// Remove like from a post
  Future<void> unlikePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.increment(-1),
      });
    } catch (e) {
      throw 'Failed to unlike post: $e';
    }
  }

  // ==================== Enhanced Real-Time Features ====================

  /// Get real-time updates for a specific post
  Stream<Map<String, dynamic>?> getPostStream(String postId) {
    return _firestore.collection('posts').doc(postId).snapshots().map((doc) {
      if (doc.exists) {
        try {
          return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
        } catch (e) {
          return {
            'id': doc.id,
            'content': 'Unable to load post',
            'error': true,
          };
        }
      }
      return null;
    });
  }

  /// Get real-time updates for posts with specific tags
  Stream<List<Map<String, dynamic>>> getTaggedPostsStream(String tag) {
    return _firestore
        .collection('posts')
        .where('tags', arrayContains: tag)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return {...data, 'id': doc.id};
            } catch (e) {
              return {
                'id': doc.id,
                'content': 'Unable to load post',
                'error': true,
              };
            }
          })
          .toList();
    });
  }

  /// Get real-time notifications for a user
  Stream<List<Map<String, dynamic>>> getUserNotificationsStream(String uid) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return {...data, 'id': doc.id};
            } catch (e) {
              return {
                'id': doc.id,
                'content': 'Unable to load notification',
                'error': true,
              };
            }
          })
          .toList();
    });
  }

  // ==================== General Read Operations ====================

  /// Query documents with filters
  Future<List<Map<String, dynamic>>> queryDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      throw 'Failed to query documents: $e';
    }
  }

  /// Get all users (for following/discovery)
  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // ==================== General Delete Operations ====================

  /// Delete entire user collection (for account deletion)
  Future<void> deleteUserAccount(String uid) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(uid).delete();

      // Delete all user's posts
      final userPosts = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();

      for (final post in userPosts.docs) {
        await post.reference.delete();
      }
    } catch (e) {
      throw 'Failed to delete user account: $e';
    }
  }
}
