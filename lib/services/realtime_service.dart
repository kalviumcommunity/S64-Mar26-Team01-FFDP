import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/job_model.dart';

/// Centralized service for all real-time Firestore synchronization
class RealtimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== CHAT/MESSAGE REAL-TIME SYNC ====================

  /// Get real-time stream of messages for a chat room
  Stream<List<MessageModel>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Chronological order
        .snapshots()
        .handleError((error) {
      return Stream.value(<MessageModel>[]);
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return MessageModel.fromFirestore(doc);
        } catch (e) {
          // Create a placeholder message for errors
          return MessageModel(
            messageId: doc.id,
            senderId: 'error',
            receiverId: 'error',
            content: 'Could not load message',
            timestamp: DateTime.now(),
            isRead: false,
          );
        }
      }).toList();
    });
  }

  /// Get real-time stream of chat rooms for a user
  Stream<List<Map<String, dynamic>>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .handleError((error) {
      return Stream.value(<List<Map<String, dynamic>>>[]);
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          return {...data, 'chatId': doc.id};
        } catch (e) {
          return {
            'chatId': doc.id,
            'error': true,
            'lastMessage': 'Could not load chat'
          };
        }
      }).toList();
    });
  }

  /// Get real-time notifications for a user
  Stream<List<Map<String, dynamic>>> getUserNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .handleError((error) {
      return Stream.value(<List<Map<String, dynamic>>>[]);
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          return {...data, 'id': doc.id};
        } catch (e) {
          return {
            'id': doc.id,
            'content': 'Could not load notification',
            'error': true,
          };
        }
      }).toList();
    });
  }

  // ==================== USER REAL-TIME SYNC ====================

  /// Get real-time updates for a user's profile
  Stream<Map<String, dynamic>?> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .handleError((error) {
      return Stream.value(null);
    }).map((doc) {
      if (!doc.exists) return null;
      try {
        return doc.data();
      } catch (e) {
        return {'error': true, 'message': 'Could not load profile'};
      }
    });
  }

  // ==================== JOB REAL-TIME SYNC ====================
  // Example for new Marketplace schema

  Stream<List<JobModel>> getActiveJobsStream(String babysitterId) {
    return _firestore
        .collection('jobs')
        .where('babysitterId', isEqualTo: babysitterId)
        .where('status', whereIn: ['pending', 'accepted', 'in_progress'])
        .snapshots().map((snapshot) {
           return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
        });
  }
}
