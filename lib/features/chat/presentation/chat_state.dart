import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/config/model_routing_config.dart';
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

extension ChatStateX on ChatState {
  /// Returns the actual model name for the header badge
  String get currentModelLabel => getCurrentModelLabel(this);
}

/// Helper function to resolve the current model label from ChatState
String getCurrentModelLabel(ChatState state) {
  for (int i = state.messages.length - 1; i >= 0; i--) {
    final m = state.messages[i];
    if (m.isAssistant && m.modelId != null && m.modelId!.isNotEmpty) {
      return ModelRoutingConfig.getModelById(m.modelId!).shortLabel;
    }
  }
  return state.selectedPlanet.modelLabel;
}
