import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/job_model.dart';
import '../models/review_model.dart';

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
      throw Exception('Failed to create user document: $e');
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
      throw Exception('Failed to fetch user document: $e');
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
    String? role,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (role != null) updates['role'] = role;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Submit Aadhaar Verification (Babysitter only)
  Future<void> submitAadhaarVerification({
    required String uid,
    required String aadhaarNumber,
    required String frontUrl,
    required String backUrl,
  }) async {
    try {
      final verificationMap = {
        'aadhaarNumber': aadhaarNumber,
        'documentFrontUrl': frontUrl,
        'documentBackUrl': backUrl,
        'status': 'pending',
        'submittedAt': Timestamp.now(),
      };
      
      await _firestore.collection('users').doc(uid).update({
        'verification': verificationMap,
      });
    } catch (e) {
      throw Exception('Failed to submit Aadhaar verification: $e');
    }
  }

  // ==================== Job Operations ====================

  /// Create a new Job Booking
  Future<String> createJob(JobModel job) async {
    try {
      final docRef = await _firestore.collection('jobs').add(job.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  /// Get real-time stream of jobs for a parent
  Stream<List<JobModel>> getParentJobsStream(String parentId) {
    return _firestore
        .collection('jobs')
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    });
  }

  /// Get real-time stream of jobs for a babysitter
  Stream<List<JobModel>> getBabysitterJobsStream(String babysitterId) {
    return _firestore
        .collection('jobs')
        .where('babysitterId', isEqualTo: babysitterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    });
  }

  /// Update Job status
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update job status: $e');
    }
  }

  // ==================== Review Operations ====================

  /// Create a new review
  Future<void> createReview(ReviewModel review) async {
    try {
      await _firestore.collection('reviews').doc(review.reviewId).set(review.toMap());
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  // ==================== Enhanced Real-Time Features ====================

  /// Get real-time notifications for a user
  Stream<List<Map<String, dynamic>>> getUserNotificationsStream(String uid) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          return {...data, 'id': doc.id};
        } catch (e) {
          return {
            'id': doc.id,
            'content': 'Unable to load notification',
            'error': true,
          };
        }
      }).toList();
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
      throw Exception('Failed to query documents: $e');
    }
  }

  /// Get all babysitters (for discovery map/list)
  Stream<List<UserModel>> getBabysittersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'babysitter')
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // ==================== General Delete Operations ====================

  /// Delete entire user account (Cleanup)
  Future<void> deleteUserAccount(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user account: $e');
    }
  }
}
