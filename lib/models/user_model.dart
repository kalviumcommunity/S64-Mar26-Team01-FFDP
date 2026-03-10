import 'package:cloud_firestore/cloud_firestore.dart';

/// User data model for NanheNest application
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final String fcmToken;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.fcmToken,
    required this.createdAt,
    required this.lastActive,
  });

  /// Convert Firestore document to UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      bio: data['bio'] ?? '',
      postCount: data['postCount'] ?? 0,
      followerCount: data['followerCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      fcmToken: data['fcmToken'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
    );
  }

  /// Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'postCount': postCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  /// Create a copy with some fields replaced
  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? postCount,
    int? followerCount,
    int? followingCount,
    String? fcmToken,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
