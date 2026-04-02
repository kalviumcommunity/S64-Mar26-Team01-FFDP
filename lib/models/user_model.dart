import 'package:cloud_firestore/cloud_firestore.dart';

/// User data model for NanheNest application (Babysitter Marketplace)
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String? phoneNumber;
  final String role; // 'parent' or 'babysitter'
  final String fcmToken;
  final DateTime createdAt;
  final DateTime lastActive;

  // Parent specific
  final int childrenCount;
  final String specialRequirements;

  // Babysitter specific
  final String bio;
  final double hourlyRate;
  final int yearsOfExperience;
  final List<String> certifications;
  final double averageRating;
  final int totalJobsCompleted;
  
  // Aadhaar Verification map
  final Map<String, dynamic>? verification;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    this.phoneNumber,
    this.role = 'parent',
    required this.fcmToken,
    required this.createdAt,
    required this.lastActive,
    this.childrenCount = 0,
    this.specialRequirements = '',
    this.bio = '',
    this.hourlyRate = 0.0,
    this.yearsOfExperience = 0,
    this.certifications = const [],
    this.averageRating = 0.0,
    this.totalJobsCompleted = 0,
    this.verification,
  });

  /// Convert Firestore document to UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      phoneNumber: data['phoneNumber'],
      role: data['role'] ?? 'parent',
      fcmToken: data['fcmToken'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      childrenCount: data['childrenCount'] ?? 0,
      specialRequirements: data['specialRequirements'] ?? '',
      bio: data['bio'] ?? '',
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      certifications: List<String>.from(data['certifications'] ?? []),
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      totalJobsCompleted: data['totalJobsCompleted'] ?? 0,
      verification: data['verification'],
    );
  }

  /// Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'role': role,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'childrenCount': childrenCount,
      'specialRequirements': specialRequirements,
      'bio': bio,
      'hourlyRate': hourlyRate,
      'yearsOfExperience': yearsOfExperience,
      'certifications': certifications,
      'averageRating': averageRating,
      'totalJobsCompleted': totalJobsCompleted,
      if (verification != null) 'verification': verification,
    };
  }

  /// Create a copy with some fields replaced
  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    String? role,
    String? fcmToken,
    DateTime? lastActive,
    int? childrenCount,
    String? specialRequirements,
    String? bio,
    double? hourlyRate,
    int? yearsOfExperience,
    List<String>? certifications,
    double? averageRating,
    int? totalJobsCompleted,
    Map<String, dynamic>? verification,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
      childrenCount: childrenCount ?? this.childrenCount,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      bio: bio ?? this.bio,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      certifications: certifications ?? this.certifications,
      averageRating: averageRating ?? this.averageRating,
      totalJobsCompleted: totalJobsCompleted ?? this.totalJobsCompleted,
      verification: verification ?? this.verification,
    );
  }
}
