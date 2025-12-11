import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/chat.dart';
import '../models/user_model.dart';

/// Comprehensive Firestore service for real-time data management
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static CollectionReference get _users => _firestore.collection('users');
  static CollectionReference get _chats => _firestore.collection('chats');

  // Note: For a scalable chat app, messages should be a sub-collection inside each chat.
  // This example uses a simplified approach for demonstration. A better structure is chats/{chatId}/messages.
  // We will follow this improved structure in the methods.

  // ==================== USER MANAGEMENT ====================

  /// Create or update user profile
  static Future<void> createUserProfile(UserModel userModel) async {
    try {
      await _users.doc(userModel.uid).set(userModel.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile: $e');
      }
      rethrow;
    }
  }

  /// Get user profile by UID
  static Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? email,
    String? profileImageUrl,
    String? status,
    String? bio,
    String? location,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      if (status != null) updateData['status'] = status;
      if (bio != null) updateData['bio'] = bio;
      if (location != null) updateData['location'] = location;

      await _users.doc(uid).update(updateData);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  /// Update user online status
  static Future<void> updateUserOnlineStatus(String uid, bool isOnline) async {
    try {
      await _users.doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating online status: $e');
      }
      rethrow;
    }
  }

  /// Search users by phone number
  static Future<List<UserModel>> searchUsersByPhone(String phone) async {
    try {
      final querySnapshot = await _users
          .where('phone', isEqualTo: phone)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching users: $e');
      }
      return [];
    }
  }

  /// Delete user profile
  static Future<void> deleteUserProfile(String uid) async {
    try {
      await _users.doc(uid).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user profile: $e');
      }
      rethrow;
    }
  }

  // ==================== CHAT MANAGEMENT ====================

  /// Create a new chat if it doesn't exist
  static Future<String> createChat({
    required String chatId,
    required List<String> participants,
  }) async {
    try {
      final chatDoc = _chats.doc(chatId);
      final docSnapshot = await chatDoc.get();

      if (!docSnapshot.exists) {
        await chatDoc.set({
          'chatId': chatId,
          'participants': participants,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }
      return chatId;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating chat: $e');
      }
      rethrow;
    }
  }

  /// Get user chats stream
  static Stream<List<Chat>> getUserChats(String userId) {
    return _chats
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Chat.fromMap(data); // Assuming Chat.fromMap exists
      }).toList();
    });
  }

  // ==================== MESSAGE MANAGEMENT ====================

  /// Send a message
  static Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required MessageType type,
    String? fileUrl,
    String? fileName,
  }) async {
    try {
      // Message data to be added
      final messageData = {
        'senderId': senderId,
        'text': text,
        'type': type.toString().split('.').last, // e.g., 'text', 'image'
        'timestamp': FieldValue.serverTimestamp(),
        'fileUrl': fileUrl,
        'fileName': fileName,
      };

      // Add message to the sub-collection
      await _chats.doc(chatId).collection('messages').add(messageData);

      // Update chat with last message info
      await _chats.doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      rethrow;
    }
  }

  /// Get messages for a chat stream
  static Stream<List<Message>> getChatMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Message.fromMap(data, doc.id); // Assuming Message.fromMap exists
      }).toList();
    });
  }

  /// Mark message as read
  static Future<void> markMessageAsRead(String chatId, String messageId) async {
    try {
      await _chats.doc(chatId).collection('messages').doc(messageId).update({'isRead': true});
    } catch (e) {
      if (kDebugMode) {
        print('Error marking message as read: $e');
      }
      rethrow;
    }
  }

  /// Delete message
  static Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _chats.doc(chatId).collection('messages').doc(messageId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting message: $e');
      }
      rethrow;
    }
  }
}
