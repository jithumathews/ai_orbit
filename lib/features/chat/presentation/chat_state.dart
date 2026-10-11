import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/conversation.dart';
import '../domain/models/planet.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required Planet selectedPlanet,
    @Default([]) List<Conversation> conversations,
    Conversation? activeConversation,
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isStreaming,
    @Default(50) int remainingQuota,
    String? lastFailedPrompt,
    String? streamError,
  }) = _ChatState;
}
