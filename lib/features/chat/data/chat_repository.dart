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
  final Map<String, List<ChatMessage>> _perPlanetHistory = {};

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
        'agent_slug': agentSlug,
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

  /// Task 2: Retrieve per-planet conversation history from chat_history table
  Future<List<ChatMessage>> getChatHistory({
    required String agentSlug,
    int limit = 10,
  }) async {
    final localList = _perPlanetHistory[agentSlug] ?? [];

    if (_auth.isMockMode || _auth.currentUserId == null || _auth.currentUserId!.startsWith('orbit-')) {
      final start = localList.length > limit ? localList.length - limit : 0;
      return List<ChatMessage>.from(localList.sublist(start));
    }

    try {
      final response = await _auth.client
          .from('chat_history')
          .select()
          .eq('agent_slug', agentSlug)
          .order('created_at', ascending: false)
          .limit(limit);

      final list = (response as List<dynamic>)
          .map((row) {
            final map = row as Map<String, dynamic>;
            return ChatMessage(
              id: map['id'] as String? ?? 'hist-${DateTime.now().millisecondsSinceEpoch}',
              role: map['role'] as String? ?? 'user',
              content: map['content'] as String? ?? '',
              modelId: map['model_used'] as String?,
              createdAt: map['created_at'] != null
                  ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
                  : DateTime.now(),
            );
          })
          .toList();

      // Return chronological order
      final reversed = list.reversed.toList();
      _perPlanetHistory[agentSlug] = reversed;
      return reversed;
    } catch (e) {
      debugPrint('[ChatRepository] Error loading chat_history ($e). Using local cache.');
      final start = localList.length > limit ? localList.length - limit : 0;
      return List<ChatMessage>.from(localList.sublist(start));
    }
  }

  /// Task 2: Save individual message into chat_history table with model_used
  Future<void> saveHistoryMessage({
    required String agentSlug,
    required String role,
    required String content,
    String? modelUsed,
  }) async {
    final msg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: role,
      content: content,
      modelId: modelUsed,
      createdAt: DateTime.now(),
    );

    _perPlanetHistory.putIfAbsent(agentSlug, () => []).add(msg);

    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      return;
    }

    try {
      final payload = <String, dynamic>{
        'agent_id': slugToAgentId[agentSlug],
        'agent_slug': agentSlug,
        'user_id': userId,
        'session_id': userId,
        'role': role,
        'content': content,
      };
      if (modelUsed != null) {
        payload['model_used'] = modelUsed;
      }

      await _auth.client.from('chat_history').insert(payload);
    } catch (e) {
      debugPrint('[ChatRepository] Failed saving message to chat_history: $e');
    }
  }

  /// Task 2: Clear conversation history for a specific planet
  Future<void> clearHistory({required String agentSlug}) async {
    _perPlanetHistory[agentSlug] = [];

    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      return;
    }

    try {
      await _auth.client
          .from('chat_history')
          .delete()
          .eq('agent_slug', agentSlug);
    } catch (e) {
      debugPrint('[ChatRepository] Failed clearing chat_history for $agentSlug: $e');
    }
  }

  Stream<GatewayEvent> streamChat({
    required String conversationId,
    required String agentSlug,
    String? modelId,
    required String message,
    List<Map<String, String>> history = const [],
    List<String> fallbackQueue = const [],
  }) {
    return _gateway.streamChat(
      conversationId: conversationId,
      agentSlug: agentSlug,
      modelId: modelId,
      message: message,
      history: history,
      fallbackQueue: fallbackQueue,
    );
  }
}
