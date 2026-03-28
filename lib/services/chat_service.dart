import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

/// Service for real-time chat functionality
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get or create a chat room between two users
  Future<String> getOrCreateChat(String uid1, String uid2) async {
    try {
      // Create a consistent chat ID by sorting UIDs
      final chatId = uid1.hashCode <= uid2.hashCode 
          ? '$uid1-$uid2' 
          : '$uid2-$uid1';
      
      // Check if chat room already exists
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!chatDoc.exists) {
        // Create new chat room
        await _firestore.collection('chats').doc(chatId).set({
          'participants': [uid1, uid2],
          'createdAt': Timestamp.now(),
          'lastMessage': '',
          'lastMessageTime': Timestamp.now(),
        });
      }
      
      return chatId;
    } catch (e) {
      throw 'Failed to get or create chat: $e';
    }
  }

  /// Send a message in a chat room
  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      // Add message to messages subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Update last message in chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp,
      });
    } catch (e) {
      throw 'Failed to send message: $e';
    }
  }

  /// Get real-time stream of messages for a chat
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw 'Failed to get messages stream: $e';
    }
  }

  /// Get real-time stream of chat rooms for a user
  Stream<List<Map<String, dynamic>>> getUserChatsStream(String userId) {
    try {
      return _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {...data, 'chatId': doc.id};
        }).toList();
      });
    } catch (e) {
      throw 'Failed to get user chats stream: $e';
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messagesQuery = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to mark messages as read: $e';
    }
  }
}