import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_model.freezed.dart';
part 'ai_model.g.dart';

@freezed
class AiModel with _$AiModel {
  const factory AiModel({
    required String id,
    required String provider,
    @JsonKey(name: 'model_id') required String modelId,
    @JsonKey(name: 'display_name') required String displayName,
    @Default([]) List<String> capabilities,
    @JsonKey(name: 'max_output_tokens') @Default(4096) int maxOutputTokens,
    @JsonKey(name: 'context_window') @Default(128000) int contextWindow,
    @JsonKey(name: 'rpm_limit') @Default(30) int rpmLimit,
    @JsonKey(name: 'daily_limit') @Default(500) int dailyLimit,
    @Default(true) bool enabled,
    @Default(1) int priority,
    @Default('healthy') String status, // 'healthy', 'degraded', 'cooldown', 'disabled'
    @JsonKey(name: 'avg_latency_ms') @Default(0) int avgLatencyMs,
    @JsonKey(name: 'error_rate') @Default(0.0) double errorRate,
  }) = _AiModel;

  factory AiModel.fromJson(Map<String, dynamic> json) => _$AiModelFromJson(json);

  static List<AiModel> defaultModels() => [
    const AiModel(
      id: '11111111-1111-1111-1111-111111111101',
      provider: 'groq',
      modelId: 'llama-3.3-70b-versatile',
      displayName: 'Groq Llama 3.3 70B',
      capabilities: ['streaming', 'chat', 'code', 'fast'],
      priority: 1,
      enabled: true,
      status: 'healthy',
    ),
    const AiModel(
      id: '11111111-1111-1111-1111-111111111102',
      provider: 'openrouter',
      modelId: 'mistralai/mistral-large-2407',
      displayName: 'OpenRouter Mistral Large',
      capabilities: ['streaming', 'chat', 'reasoning'],
      priority: 2,
      enabled: true,
      status: 'healthy',
    ),
    const AiModel(
      id: '11111111-1111-1111-1111-111111111103',
      provider: 'together',
      modelId: 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
      displayName: 'Together Llama 3.1 8B',
      capabilities: ['streaming', 'fast', 'fallback'],
      priority: 3,
      enabled: true,
      status: 'healthy',
    ),
  ];
}
