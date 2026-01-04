import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get or create conversation between two users
  Future<String> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      // Check if conversation already exists
      final existingConversations = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in existingConversations.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }

      // Create new conversation
      final conversationRef = await _firestore.collection('conversations').add({
        'participants': [currentUserId, otherUserId],
        'lastMessage': null,
        'lastMessageTime': null,
        'unreadCount': {currentUserId: 0, otherUserId: 0},
      });

      return conversationRef.id;
    } catch (e) {
      throw 'Erreur lors de la création de la conversation: $e';
    }
  }

  // Send text message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    try {
      final message = MessageModel(
        id: '',
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      // Add message to messages collection
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(message.toMap());

      // Update conversation with last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount.$receiverId': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Erreur lors de l\'envoi du message: $e';
    }
  }

  // Upload voice message to Supabase Storage
  Future<String> uploadVoiceMessage(
    String filePath,
    String conversationId,
  ) async {
    try {
      print('🔵 Uploading voice message to Supabase from: $filePath');
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storagePath = '$conversationId/$fileName';

      if (kIsWeb) {
        throw 'Les messages vocaux ne sont pas supportés sur le web. Utilisez l\'application mobile.';
      } else {
        // For mobile, use File API with Supabase
        print('🟡 Checking if file exists: $filePath');
        final file = File(filePath);

        if (!await file.exists()) {
          throw 'Le fichier audio n\'existe pas: $filePath';
        }

        print('🟡 File size: ${await file.length()} bytes');

        // Upload to Supabase Storage
        final response = await _supabase.storage
            .from('voiceapp')
            .upload(storagePath, file);

        print('🟡 Upload completed, creating signed URL...');

        // Create a signed URL that's valid for 1 year
        final signedUrl = await _supabase.storage
            .from('voiceapp')
            .createSignedUrl(storagePath, 31536000); // 1 year in seconds

        print('🟢 Voice message uploaded to Supabase: $signedUrl');
        return signedUrl;
      }
    } catch (e) {
      print('🔴 Error uploading voice message to Supabase: $e');
      throw 'Erreur lors de l\'upload du message vocal: $e';
    }
  }

  // Send voice message
  Future<void> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String audioPath,
  }) async {
    try {
      // Upload audio file to Firebase Storage
      final audioUrl = await uploadVoiceMessage(audioPath, conversationId);

      final message = MessageModel(
        id: '',
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        audioUrl: audioUrl,
        type: MessageType.voice,
        timestamp: DateTime.now(),
      );

      // Add message to messages collection
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(message.toMap());

      // Update conversation with last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': '🎤 Message vocal',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount.$receiverId': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Erreur lors de l\'envoi du message vocal: $e';
    }
  }

  // Get messages stream for a conversation
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get user conversations stream
  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    print('🔵 ChatRepository: Querying conversations for userId: $userId');
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .handleError((error) {
          print('🔴 ChatRepository: Firestore error: $error');
        })
        .map((snapshot) {
          print(
            '🟢 ChatRepository: Got ${snapshot.docs.length} documents from Firestore',
          );
          return snapshot.docs.map((doc) {
            print('   - Document ID: ${doc.id}');
            return ConversationModel.fromMap(doc.data(), doc.id);
          }).toList()..sort((a, b) {
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });
        });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      throw 'Erreur lors du marquage des messages: $e';
    }
  }

  // Search users by name or email
  Future<List<UserModel>> searchUsers(
    String query,
    String currentUserId,
  ) async {
    try {
      if (query.isEmpty) return [];

      final usersSnapshot = await _firestore.collection('users').get();

      final users = usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where(
            (user) =>
                user.uid != currentUserId &&
                (user.displayName.toLowerCase().contains(query.toLowerCase()) ||
                    user.email.toLowerCase().contains(query.toLowerCase())),
          )
          .toList();

      return users;
    } catch (e) {
      throw 'Erreur lors de la recherche: $e';
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw 'Erreur lors de la récupération de l\'utilisateur: $e';
    }
  }
}
