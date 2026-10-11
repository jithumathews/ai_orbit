import 'package:freezed_annotation/freezed_annotation.dart';
import 'chat_source.dart';

part 'chat_message.freezed.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String role, // 'user', 'assistant', 'system'
    required String content,
    required DateTime createdAt,
    @Default(false) bool isStreaming,
    @Default(false) bool isError,
    String? errorMessage,
    String? modelRunId,
    String? fallbackFrom,
    String? modelId,
    String? provider,
    @Default([]) List<ChatSource> sources,
    @Default(false) bool searchedWeb,
    String? searchDate,
    String? searchQuery,
  }) = _ChatMessage;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      modelRunId: json['model_run_id'] as String?,
      fallbackFrom: json['fallback_from'] as String?,
      modelId: json['model_id'] as String?,
      provider: json['provider'] as String?,
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => ChatSource.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      searchedWeb: json['searched_web'] as bool? ?? false,
      searchDate: json['search_date'] as String?,
      searchQuery: json['search_query'] as String?,
    );
  }
}
