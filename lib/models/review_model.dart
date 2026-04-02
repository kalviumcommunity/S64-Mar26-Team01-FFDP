import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a review left by a parent for a babysitter
class ReviewModel {
  final String reviewId;
  final String jobId;
  final String parentId;
  final String babysitterId;
  final double rating;
  final String feedback;
  final DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.jobId,
    required this.parentId,
    required this.babysitterId,
    required this.rating,
    required this.feedback,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      reviewId: doc.id,
      jobId: data['jobId'] ?? '',
      parentId: data['parentId'] ?? '',
      babysitterId: data['babysitterId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      feedback: data['feedback'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'parentId': parentId,
      'babysitterId': babysitterId,
      'rating': rating,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
