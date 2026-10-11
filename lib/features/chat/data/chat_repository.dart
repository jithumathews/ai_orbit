import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/ai_model.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/conversation.dart';
import '../../auth/data/auth_repository.dart';
import 'ai_gateway_data_source.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final gateway = ref.watch(aiGatewayDataSourceProvider);
  return ChatRepository(authRepo, gateway);
});

class ChatRepository {
  final AuthRepository _auth;
  final AiGatewayDataSource _gateway;

  final List<Conversation> _mockConversations = [];

  ChatRepository(this._auth, this._gateway);

  Future<List<AiModel>> getEnabledModels() async {
    if (_auth.isMockMode) {
      return AiModel.defaultModels();
    }

    try {
      final response = await _auth.client
          .from('ai_models')
          .select()
          .eq('enabled', true)
          .order('priority', ascending: true);

      return (response as List<dynamic>)
          .map((row) => AiModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ChatRepository] Error loading remote models: $e');
      return AiModel.defaultModels();
    }
  }

  Future<List<Conversation>> getConversations() async {
    if (_auth.isMockMode) {
      return List<Conversation>.from(_mockConversations);
    }

    try {
      final response = await _auth.client
          .from('conversations')
          .select()
          .order('updated_at', ascending: false);

      return (response as List<dynamic>)
          .map((row) => Conversation.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ChatRepository] Error loading conversations: $e');
      return [];
    }
  }

  Future<Conversation> createConversation({
    required String agentSlug,
    String? modelId,
    String title = 'New Orbital Transmission',
  }) async {
    final userId = _auth.currentUserId;

    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      final conv = Conversation(
        id: 'conv-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId ?? 'orbit-local-user',
        agentSlug: agentSlug,
        agentId: slugToAgentId[agentSlug],
        modelId: modelId,
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockConversations.insert(0, conv);
      return conv;
    }

    try {
      final agentId = slugToAgentId[agentSlug] ?? '22222222-2222-2222-2222-222222222201';
      final payload = <String, dynamic>{
        'user_id': userId,
        'agent_id': agentId,
        'title': title,
      };
      if (modelId != null) payload['model_id'] = modelId;

      final response = await _auth.client
          .from('conversations')
          .insert(payload)
          .select()
          .single();

      return Conversation.fromJson(response);
    } catch (e) {
      debugPrint('[ChatRepository] Supabase conversation insert failed ($e). Using local fallback conversation.');
      final fallbackConv = Conversation(
        id: 'conv-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        agentSlug: agentSlug,
        agentId: slugToAgentId[agentSlug],
        modelId: modelId,
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockConversations.insert(0, fallbackConv);
      return fallbackConv;
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    if (_auth.isMockMode) {
      return [];
    }

    try {
      final response = await _auth.client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .map((row) => ChatMessage.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ChatRepository] Error fetching messages: $e');
      return [];
    }
  }

  Stream<GatewayEvent> streamChat({
    required String conversationId,
    required String agentSlug,
    String? modelId,
    required String message,
  }) {
    return _gateway.streamChat(
      conversationId: conversationId,
      agentSlug: agentSlug,
      modelId: modelId,
      message: message,
    );
  }
}
