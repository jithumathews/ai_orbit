// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // 'user', 'assistant', 'system'
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  bool get isError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'model_run_id')
  String? get modelRunId => throw _privateConstructorUsedError;
  @JsonKey(name: 'fallback_from')
  String? get fallbackFrom => throw _privateConstructorUsedError;
  @JsonKey(name: 'model_id')
  String? get modelId => throw _privateConstructorUsedError;
  String? get provider => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String role,
    String content,
    @JsonKey(name: 'created_at') DateTime createdAt,
    bool isStreaming,
    bool isError,
    String? errorMessage,
    @JsonKey(name: 'model_run_id') String? modelRunId,
    @JsonKey(name: 'fallback_from') String? fallbackFrom,
    @JsonKey(name: 'model_id') String? modelId,
    String? provider,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = null,
    Object? isStreaming = null,
    Object? isError = null,
    Object? errorMessage = freezed,
    Object? modelRunId = freezed,
    Object? fallbackFrom = freezed,
    Object? modelId = freezed,
    Object? provider = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isStreaming: null == isStreaming
                ? _value.isStreaming
                : isStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            isError: null == isError
                ? _value.isError
                : isError // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            modelRunId: freezed == modelRunId
                ? _value.modelRunId
                : modelRunId // ignore: cast_nullable_to_non_nullable
                      as String?,
            fallbackFrom: freezed == fallbackFrom
                ? _value.fallbackFrom
                : fallbackFrom // ignore: cast_nullable_to_non_nullable
                      as String?,
            modelId: freezed == modelId
                ? _value.modelId
                : modelId // ignore: cast_nullable_to_non_nullable
                      as String?,
            provider: freezed == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String role,
    String content,
    @JsonKey(name: 'created_at') DateTime createdAt,
    bool isStreaming,
    bool isError,
    String? errorMessage,
    @JsonKey(name: 'model_run_id') String? modelRunId,
    @JsonKey(name: 'fallback_from') String? fallbackFrom,
    @JsonKey(name: 'model_id') String? modelId,
    String? provider,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = null,
    Object? isStreaming = null,
    Object? isError = null,
    Object? errorMessage = freezed,
    Object? modelRunId = freezed,
    Object? fallbackFrom = freezed,
    Object? modelId = freezed,
    Object? provider = freezed,
  }) {
    return _then(
      _$ChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isStreaming: null == isStreaming
            ? _value.isStreaming
            : isStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        isError: null == isError
            ? _value.isError
            : isError // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        modelRunId: freezed == modelRunId
            ? _value.modelRunId
            : modelRunId // ignore: cast_nullable_to_non_nullable
                  as String?,
        fallbackFrom: freezed == fallbackFrom
            ? _value.fallbackFrom
            : fallbackFrom // ignore: cast_nullable_to_non_nullable
                  as String?,
        modelId: freezed == modelId
            ? _value.modelId
            : modelId // ignore: cast_nullable_to_non_nullable
                  as String?,
        provider: freezed == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl extends _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.role,
    required this.content,
    @JsonKey(name: 'created_at') required this.createdAt,
    this.isStreaming = false,
    this.isError = false,
    this.errorMessage,
    @JsonKey(name: 'model_run_id') this.modelRunId,
    @JsonKey(name: 'fallback_from') this.fallbackFrom,
    @JsonKey(name: 'model_id') this.modelId,
    this.provider,
  }) : super._();

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String role;
  // 'user', 'assistant', 'system'
  @override
  final String content;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isStreaming;
  @override
  @JsonKey()
  final bool isError;
  @override
  final String? errorMessage;
  @override
  @JsonKey(name: 'model_run_id')
  final String? modelRunId;
  @override
  @JsonKey(name: 'fallback_from')
  final String? fallbackFrom;
  @override
  @JsonKey(name: 'model_id')
  final String? modelId;
  @override
  final String? provider;

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, content: $content, createdAt: $createdAt, isStreaming: $isStreaming, isError: $isError, errorMessage: $errorMessage, modelRunId: $modelRunId, fallbackFrom: $fallbackFrom, modelId: $modelId, provider: $provider)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.isError, isError) || other.isError == isError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.modelRunId, modelRunId) ||
                other.modelRunId == modelRunId) &&
            (identical(other.fallbackFrom, fallbackFrom) ||
                other.fallbackFrom == fallbackFrom) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.provider, provider) ||
                other.provider == provider));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    role,
    content,
    createdAt,
    isStreaming,
    isError,
    errorMessage,
    modelRunId,
    fallbackFrom,
    modelId,
    provider,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage extends ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String role,
    required final String content,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    final bool isStreaming,
    final bool isError,
    final String? errorMessage,
    @JsonKey(name: 'model_run_id') final String? modelRunId,
    @JsonKey(name: 'fallback_from') final String? fallbackFrom,
    @JsonKey(name: 'model_id') final String? modelId,
    final String? provider,
  }) = _$ChatMessageImpl;
  const _ChatMessage._() : super._();

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get role; // 'user', 'assistant', 'system'
  @override
  String get content;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  bool get isStreaming;
  @override
  bool get isError;
  @override
  String? get errorMessage;
  @override
  @JsonKey(name: 'model_run_id')
  String? get modelRunId;
  @override
  @JsonKey(name: 'fallback_from')
  String? get fallbackFrom;
  @override
  @JsonKey(name: 'model_id')
  String? get modelId;
  @override
  String? get provider;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
