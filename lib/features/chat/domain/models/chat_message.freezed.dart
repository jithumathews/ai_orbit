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

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // 'user', 'assistant', 'system'
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  bool get isError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get modelRunId => throw _privateConstructorUsedError;
  String? get fallbackFrom => throw _privateConstructorUsedError;
  String? get modelId => throw _privateConstructorUsedError;
  String? get provider => throw _privateConstructorUsedError;
  List<ChatSource> get sources => throw _privateConstructorUsedError;
  bool get searchedWeb => throw _privateConstructorUsedError;
  String? get searchDate => throw _privateConstructorUsedError;
  String? get searchQuery => throw _privateConstructorUsedError;

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
    DateTime createdAt,
    bool isStreaming,
    bool isError,
    String? errorMessage,
    String? modelRunId,
    String? fallbackFrom,
    String? modelId,
    String? provider,
    List<ChatSource> sources,
    bool searchedWeb,
    String? searchDate,
    String? searchQuery,
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
    Object? sources = null,
    Object? searchedWeb = null,
    Object? searchDate = freezed,
    Object? searchQuery = freezed,
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
            sources: null == sources
                ? _value.sources
                : sources // ignore: cast_nullable_to_non_nullable
                      as List<ChatSource>,
            searchedWeb: null == searchedWeb
                ? _value.searchedWeb
                : searchedWeb // ignore: cast_nullable_to_non_nullable
                      as bool,
            searchDate: freezed == searchDate
                ? _value.searchDate
                : searchDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            searchQuery: freezed == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
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
    DateTime createdAt,
    bool isStreaming,
    bool isError,
    String? errorMessage,
    String? modelRunId,
    String? fallbackFrom,
    String? modelId,
    String? provider,
    List<ChatSource> sources,
    bool searchedWeb,
    String? searchDate,
    String? searchQuery,
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
    Object? sources = null,
    Object? searchedWeb = null,
    Object? searchDate = freezed,
    Object? searchQuery = freezed,
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
        sources: null == sources
            ? _value._sources
            : sources // ignore: cast_nullable_to_non_nullable
                  as List<ChatSource>,
        searchedWeb: null == searchedWeb
            ? _value.searchedWeb
            : searchedWeb // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchDate: freezed == searchDate
            ? _value.searchDate
            : searchDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        searchQuery: freezed == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ChatMessageImpl extends _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isStreaming = false,
    this.isError = false,
    this.errorMessage,
    this.modelRunId,
    this.fallbackFrom,
    this.modelId,
    this.provider,
    final List<ChatSource> sources = const [],
    this.searchedWeb = false,
    this.searchDate,
    this.searchQuery,
  }) : _sources = sources,
       super._();

  @override
  final String id;
  @override
  final String role;
  // 'user', 'assistant', 'system'
  @override
  final String content;
  @override
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
  final String? modelRunId;
  @override
  final String? fallbackFrom;
  @override
  final String? modelId;
  @override
  final String? provider;
  final List<ChatSource> _sources;
  @override
  @JsonKey()
  List<ChatSource> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  @JsonKey()
  final bool searchedWeb;
  @override
  final String? searchDate;
  @override
  final String? searchQuery;

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, content: $content, createdAt: $createdAt, isStreaming: $isStreaming, isError: $isError, errorMessage: $errorMessage, modelRunId: $modelRunId, fallbackFrom: $fallbackFrom, modelId: $modelId, provider: $provider, sources: $sources, searchedWeb: $searchedWeb, searchDate: $searchDate, searchQuery: $searchQuery)';
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
                other.provider == provider) &&
            const DeepCollectionEquality().equals(other._sources, _sources) &&
            (identical(other.searchedWeb, searchedWeb) ||
                other.searchedWeb == searchedWeb) &&
            (identical(other.searchDate, searchDate) ||
                other.searchDate == searchDate) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery));
  }

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
    const DeepCollectionEquality().hash(_sources),
    searchedWeb,
    searchDate,
    searchQuery,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);
}

abstract class _ChatMessage extends ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String role,
    required final String content,
    required final DateTime createdAt,
    final bool isStreaming,
    final bool isError,
    final String? errorMessage,
    final String? modelRunId,
    final String? fallbackFrom,
    final String? modelId,
    final String? provider,
    final List<ChatSource> sources,
    final bool searchedWeb,
    final String? searchDate,
    final String? searchQuery,
  }) = _$ChatMessageImpl;
  const _ChatMessage._() : super._();

  @override
  String get id;
  @override
  String get role; // 'user', 'assistant', 'system'
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  bool get isStreaming;
  @override
  bool get isError;
  @override
  String? get errorMessage;
  @override
  String? get modelRunId;
  @override
  String? get fallbackFrom;
  @override
  String? get modelId;
  @override
  String? get provider;
  @override
  List<ChatSource> get sources;
  @override
  bool get searchedWeb;
  @override
  String? get searchDate;
  @override
  String? get searchQuery;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
