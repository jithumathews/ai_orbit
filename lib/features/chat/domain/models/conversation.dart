import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';

const Map<String, String> slugToAgentId = {
  'general': '22222222-2222-2222-2222-222222222201',
  'coding': '22222222-2222-2222-2222-222222222202',
  'creative': '22222222-2222-2222-2222-222222222203',
  'reasoning': '22222222-2222-2222-2222-222222222204',
  'research': '22222222-2222-2222-2222-222222222205',
};

const Map<String, String> agentIdToSlug = {
  '22222222-2222-2222-2222-222222222201': 'general',
  '22222222-2222-2222-2222-222222222202': 'coding',
  '22222222-2222-2222-2222-222222222203': 'creative',
  '22222222-2222-2222-2222-222222222204': 'reasoning',
  '22222222-2222-2222-2222-222222222205': 'research',
};

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String userId,
    String? agentId,
    @Default('general') String agentSlug,
    String? modelId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final agentId = json['agent_id'] as String?;
    final slug = json['agent_slug'] as String? ?? (agentId != null ? agentIdToSlug[agentId] : null) ?? 'general';
    return Conversation(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      agentId: agentId ?? slugToAgentId[slug],
      agentSlug: slug,
      modelId: json['model_id'] as String?,
      title: json['title'] as String? ?? 'Orbital Transmission',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
