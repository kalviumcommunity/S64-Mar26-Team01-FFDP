import 'package:cloud_firestore/cloud_firestore.dart';

/// Post model for real-time feed functionality
class PostModel {
  final String postId;
  final String uid;
  final String displayName;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  PostModel({
    required this.postId,
    required this.uid,
    required this.displayName,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
  });

  /// Create a PostModel from Firestore document
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    // Handle completely missing data
    if (data == null) {
      return PostModel(
        postId: doc.id,
        uid: 'unknown',
        displayName: 'Unknown User',
        content: 'This post could not be loaded.',
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: [],
      );
    }
    
    return PostModel(
      postId: doc.id,
      uid: data['uid'] as String? ?? 'unknown',
      displayName: data['displayName'] as String? ?? 'Anonymous',
      content: data['content'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      likes: data['likes'] as int? ?? 0,
      comments: data['comments'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: data['tags'] is List ? List<String>.from(data['tags']) : [],
    );
  }

  /// Convert PostModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'content': content,
      'imageUrl': imageUrl ?? '',
      'likes': likes,
      'comments': comments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
    };
  }

  /// Create a copy with updated values
  PostModel copyWith({
    String? postId,
    String? uid,
    String? displayName,
    String? content,
    String? imageUrl,
    int? likes,
    int? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}