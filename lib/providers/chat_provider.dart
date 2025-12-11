import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/message.dart'; // Message model ko import karein

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentChatId;
  String? get currentChatId => _currentChatId;

  /// Firestore se tamam users ki live stream hasil karein (maujooda user ke ilawa)
  Stream<List<UserModel>> getUsersStream(String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  /// Maujooda chat ko set karein
  void setCurrentChat(String chatId) {
    _currentChatId = chatId;
    notifyListeners();
  }

  /// Ek specific chat ke messages ki live stream hasil karein
  Stream<List<Message>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Text message bhejein
  Future<void> sendTextMessage({
    required String chatId,
    required String receiverId,
    required String text,
    required String senderId,
  }) async {
    if (text.trim().isEmpty) return;

    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.now(),
      'type': 'text',
    };

    // Message ko chat ke andar 'messages' sub-collection mein add karein
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
  }
}

