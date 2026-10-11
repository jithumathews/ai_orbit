// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isStreaming: json['isStreaming'] as bool? ?? false,
      isError: json['isError'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      modelRunId: json['model_run_id'] as String?,
      fallbackFrom: json['fallback_from'] as String?,
      modelId: json['model_id'] as String?,
      provider: json['provider'] as String?,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
      'isStreaming': instance.isStreaming,
      'isError': instance.isError,
      'errorMessage': instance.errorMessage,
      'model_run_id': instance.modelRunId,
      'fallback_from': instance.fallbackFrom,
      'model_id': instance.modelId,
      'provider': instance.provider,
    };
