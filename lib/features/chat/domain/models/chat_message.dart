import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String role, // 'user', 'assistant', 'system'
    required String content,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default(false) bool isStreaming,
    @Default(false) bool isError,
    String? errorMessage,
    @JsonKey(name: 'model_run_id') String? modelRunId,
    @JsonKey(name: 'fallback_from') String? fallbackFrom,
    @JsonKey(name: 'model_id') String? modelId,
    String? provider,
  }) = _ChatMessage;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}
