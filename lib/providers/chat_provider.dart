import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/models/message_model.dart';
import '../data/models/conversation_model.dart';
import '../data/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  List<ConversationModel> _conversations = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ConversationModel> get conversations => _conversations;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Listen to conversations
  void listenToConversations(String userId) {
    print(
      '🔵 ChatProvider: Starting to listen for conversations for user: $userId',
    );
    _chatRepository
        .getConversationsStream(userId)
        .listen(
          (conversations) {
            print(
              '🟢 ChatProvider: Received ${conversations.length} conversations',
            );
            for (var conv in conversations) {
              print(
                '   - Conversation ID: ${conv.id}, Participants: ${conv.participants}',
              );
            }
            _conversations = conversations;
            notifyListeners();
          },
          onError: (error) {
            print('🔴 ChatProvider: Error loading conversations: $error');
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  // Send text message
  Future<bool> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    try {
      _errorMessage = null;
      await _chatRepository.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send voice message
  Future<bool> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String audioPath,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _chatRepository.sendVoiceMessage(
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        audioPath: audioPath,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get or create conversation
  Future<String?> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final conversationId = await _chatRepository.getOrCreateConversation(
        currentUserId,
        otherUserId,
      );

      _isLoading = false;
      notifyListeners();
      return conversationId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Search users
  Future<void> searchUsers(String query, String currentUserId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _searchResults = await _chatRepository.searchUsers(query, currentUserId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get messages stream
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _chatRepository.getMessagesStream(conversationId);
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _chatRepository.getUserById(userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Mark as read
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _chatRepository.markMessagesAsRead(conversationId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
