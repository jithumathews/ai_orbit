import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/orbit_config.dart';
import '../../../core/config/model_routing_config.dart';
import '../data/chat_repository.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/conversation.dart';
import '../domain/models/planet.dart';
import 'chat_state.dart';
import 'planet_notifier.dart';

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});

class ChatNotifier extends Notifier<ChatState> {
  // Use a getter so Riverpod rebuild never causes LateInitializationError
  ChatRepository get _repository => ref.read(chatRepositoryProvider);
  StreamSubscription? _streamSub;
  String? _currentRoutingModelId;

  @override
  ChatState build() {
    final initialPlanet = ref.read(planetNotifierProvider);

    ref.onDispose(() {
      _streamSub?.cancel();
    });

    return ChatState(
      selectedPlanet: initialPlanet,
      remainingQuota: 50,
    );
  }

  Future<void> bootstrap() async {
    final convs = await _repository.getConversations();

    // Task 2: Load initial planet's separate history
    final history = await _repository.getChatHistory(
      agentSlug: state.selectedPlanet.slug,
      limit: OrbitConfig.maxHistoryMessages,
    );

    state = state.copyWith(
      conversations: convs,
      messages: history,
    );

    if (convs.isNotEmpty) {
      state = state.copyWith(activeConversation: convs.first);
    } else {
      await startNewConversation();
    }
  }

  /// Task 2: Switch planet and load separate conversation history for this planet
  Future<void> switchPlanet(Planet planet) async {
    if (planet.slug == state.selectedPlanet.slug) return;
    if (state.isStreaming && state.messages.isNotEmpty) {
      final lastMsg = state.messages.last;
      if (lastMsg.isAssistant && lastMsg.content.isNotEmpty) {
        _repository.saveHistoryMessage(
          agentSlug: state.selectedPlanet.slug,
          role: 'assistant',
          content: lastMsg.content,
          modelUsed: lastMsg.modelId,
        );
      }
    }
    _streamSub?.cancel();
    ref.read(planetNotifierProvider.notifier).selectPlanet(planet);

    final history = await _repository.getChatHistory(
      agentSlug: planet.slug,
      limit: OrbitConfig.maxHistoryMessages,
    );

    state = state.copyWith(
      selectedPlanet: planet,
      messages: history,
      isStreaming: false,
      streamError: null,
    );
  }

  Future<void> selectConversation(Conversation conv) async {
    final planet = Planet.bySlug(conv.agentSlug);
    ref.read(planetNotifierProvider.notifier).selectPlanet(planet);

    final history = await _repository.getChatHistory(
      agentSlug: conv.agentSlug,
      limit: OrbitConfig.maxHistoryMessages,
    );

    state = state.copyWith(
      activeConversation: conv,
      selectedPlanet: planet,
      messages: history,
      streamError: null,
    );
  }

  Future<void> startNewConversation() async {
    final newConv = await _repository.createConversation(
      agentSlug: state.selectedPlanet.slug,
      title: 'Transmission: ${state.selectedPlanet.name}',
    );

    state = state.copyWith(
      activeConversation: newConv,
      conversations: [newConv, ...state.conversations],
      streamError: null,
    );
  }

  /// Task 2: Clear active planet's conversation history
  Future<void> clearActivePlanetHistory() async {
    await _repository.clearHistory(agentSlug: state.selectedPlanet.slug);
    state = state.copyWith(messages: []);
  }

  /// Task 3 & Task 2: Send message with prompt analysis, model routing, history context & saving
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isStreaming) return;

    if (state.activeConversation == null) {
      await startNewConversation();
    }

    state = state.copyWith(lastFailedPrompt: trimmed, streamError: null);

    // Task 3: Analyze prompt type & complexity, pick best OpenRouter free model within planet rules
    final routing = ModelRouter.route(
      planetSlug: state.selectedPlanet.slug,
      prompt: trimmed,
    );
    final chosenModel = routing.chosenModel;
    final fallbackModels = routing.fallbackQueue.map((m) => m.id).toList();
    _currentRoutingModelId = chosenModel.id;

    // Task 2: Retrieve the last N messages (default 10) to send as context
    final validHistory = state.messages
        .where((m) => !m.isError && m.content.isNotEmpty)
        .toList();
    final startIdx = validHistory.length > OrbitConfig.maxHistoryMessages
        ? validHistory.length - OrbitConfig.maxHistoryMessages
        : 0;
    final historyToSend = validHistory
        .sublist(startIdx)
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    // Create user and assistant bubble
    final userMsg = ChatMessage(
      id: 'msg-usr-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
      modelId: chosenModel.id,
    );

    final assistantMsg = ChatMessage(
      id: 'msg-ast-${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
      modelId: chosenModel.id, // Header badge immediately shows chosen model
    );

    final updatedMessages = [...state.messages, userMsg, assistantMsg];
    state = state.copyWith(messages: updatedMessages, isStreaming: true);

    // Task 2: Save user message in chat_history
    await _repository.saveHistoryMessage(
      agentSlug: state.selectedPlanet.slug,
      role: 'user',
      content: trimmed,
      modelUsed: chosenModel.id,
    );

    _streamSub?.cancel();
    _streamSub = _repository
        .streamChat(
          conversationId: state.activeConversation!.id,
          agentSlug: state.selectedPlanet.slug,
          modelId: chosenModel.id,
          fallbackQueue: fallbackModels,
          history: historyToSend,
          message: trimmed,
        )
        .listen(
          (event) {
            _handleStreamEvent(event);
          },
          onError: (err) {
            _handleStreamError(err.toString());
          },
          onDone: () {
            _handleStreamDone();
          },
        );
  }

  void _handleStreamEvent(dynamic event) {
    final currentMsgs = List<ChatMessage>.from(state.messages);
    if (currentMsgs.isEmpty) return;

    final lastIdx = currentMsgs.length - 1;
    final lastMsg = currentMsgs[lastIdx];

    if (event.type == 'token' && event.delta != null) {
      currentMsgs[lastIdx] = lastMsg.copyWith(
        content: lastMsg.content + event.delta!,
        isStreaming: true,
      );
      state = state.copyWith(messages: currentMsgs);
    } else if (event.type == 'search') {
      currentMsgs[lastIdx] = lastMsg.copyWith(
        searchedWeb: true,
        searchQuery: event.searchQuery,
      );
      state = state.copyWith(messages: currentMsgs);
    } else if (event.type == 'sources') {
      currentMsgs[lastIdx] = lastMsg.copyWith(
        sources: event.sources ?? [],
        searchedWeb: true,
        searchDate: DateTime.now().toIso8601String().split('T')[0],
      );
      state = state.copyWith(messages: currentMsgs);
    } else if (event.type == 'fallback') {
      // Task 3: Handle automatic model cascade when rate limit or error occurs
      final fallbackToModel = event.fallbackTo ?? _currentRoutingModelId;
      _currentRoutingModelId = fallbackToModel;
      currentMsgs[lastIdx] = lastMsg.copyWith(
        fallbackFrom: event.fallbackFrom,
        modelId: fallbackToModel,
        provider: event.provider,
      );
      state = state.copyWith(messages: currentMsgs);
    } else if (event.type == 'error') {
      currentMsgs[lastIdx] = lastMsg.copyWith(
        isError: true,
        errorMessage: event.message ?? 'Transmission error occurred.',
        isStreaming: false,
      );
      state = state.copyWith(
        messages: currentMsgs,
        isStreaming: false,
        streamError: event.message,
      );
    } else if (event.type == 'done') {
      final finalModelId = event.modelId ?? _currentRoutingModelId ?? lastMsg.modelId;
      currentMsgs[lastIdx] = lastMsg.copyWith(
        isStreaming: false,
        modelRunId: event.modelRunId,
        modelId: finalModelId,
      );
      final newQuota = state.remainingQuota > 0 ? state.remainingQuota - 1 : 0;
      state = state.copyWith(
        messages: currentMsgs,
        isStreaming: false,
        remainingQuota: newQuota,
      );

      // Task 2: Save assistant reply in chat_history with actual model used
      if (lastMsg.content.isNotEmpty) {
        _repository.saveHistoryMessage(
          agentSlug: state.selectedPlanet.slug,
          role: 'assistant',
          content: lastMsg.content,
          modelUsed: finalModelId,
        );
      }
    }
  }

  void _handleStreamError(String err) {
    final currentMsgs = List<ChatMessage>.from(state.messages);
    if (currentMsgs.isNotEmpty) {
      final lastIdx = currentMsgs.length - 1;
      currentMsgs[lastIdx] = currentMsgs[lastIdx].copyWith(
        isError: true,
        errorMessage: 'Orbital connection lost: $err',
        isStreaming: false,
      );
    }
    state = state.copyWith(
      messages: currentMsgs,
      isStreaming: false,
      streamError: err,
    );
  }

  void _handleStreamDone() {
    if (state.isStreaming) {
      final currentMsgs = List<ChatMessage>.from(state.messages);
      if (currentMsgs.isNotEmpty) {
        final lastIdx = currentMsgs.length - 1;
        currentMsgs[lastIdx] = currentMsgs[lastIdx].copyWith(isStreaming: false);
      }
      state = state.copyWith(messages: currentMsgs, isStreaming: false);
    }
  }

  void retryLastMessage() {
    if (state.lastFailedPrompt != null && !state.isStreaming) {
      if (state.messages.isNotEmpty && state.messages.last.isAssistant && state.messages.last.isError) {
        final msgs = List<ChatMessage>.from(state.messages)..removeLast();
        state = state.copyWith(messages: msgs);
      }
      sendMessage(state.lastFailedPrompt!);
    }
  }
}
