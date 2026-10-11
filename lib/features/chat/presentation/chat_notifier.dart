import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  ChatState build() {
    final initialPlanet = ref.watch(planetNotifierProvider);

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

    state = state.copyWith(
      conversations: convs,
    );

    if (convs.isNotEmpty) {
      await selectConversation(convs.first);
    } else {
      await startNewConversation();
    }
  }

  Future<void> switchPlanet(Planet planet) async {
    if (planet.slug == state.selectedPlanet.slug) return;
    ref.read(planetNotifierProvider.notifier).selectPlanet(planet);
    state = state.copyWith(selectedPlanet: planet);
    await startNewConversation();
  }

  Future<void> selectConversation(Conversation conv) async {
    final planet = Planet.bySlug(conv.agentSlug);
    ref.read(planetNotifierProvider.notifier).selectPlanet(planet);

    final history = await _repository.getMessages(conv.id);

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
      messages: [],
      streamError: null,
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isStreaming) return;

    if (state.activeConversation == null) {
      await startNewConversation();
    }

    state = state.copyWith(lastFailedPrompt: trimmed, streamError: null);

    final userMsg = ChatMessage(
      id: 'msg-usr-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    );

    final assistantMsg = ChatMessage(
      id: 'msg-ast-${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );

    final updatedMessages = [...state.messages, userMsg, assistantMsg];
    state = state.copyWith(messages: updatedMessages, isStreaming: true);

    _streamSub?.cancel();
    _streamSub = _repository
        .streamChat(
          conversationId: state.activeConversation!.id,
          agentSlug: state.selectedPlanet.slug,
          modelId: null, // gateway selects model from agent's default_model_id
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
    } else if (event.type == 'fallback') {
      currentMsgs[lastIdx] = lastMsg.copyWith(
        fallbackFrom: event.fallbackFrom,
        modelId: event.fallbackTo,
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
      currentMsgs[lastIdx] = lastMsg.copyWith(
        isStreaming: false,
        modelRunId: event.modelRunId,
      );
      final newQuota = state.remainingQuota > 0 ? state.remainingQuota - 1 : 0;
      state = state.copyWith(
        messages: currentMsgs,
        isStreaming: false,
        remainingQuota: newQuota,
      );
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
