// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChatState {
  Planet get selectedPlanet => throw _privateConstructorUsedError;
  List<Conversation> get conversations => throw _privateConstructorUsedError;
  Conversation? get activeConversation => throw _privateConstructorUsedError;
  List<ChatMessage> get messages => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  int get remainingQuota => throw _privateConstructorUsedError;
  String? get lastFailedPrompt => throw _privateConstructorUsedError;
  String? get streamError => throw _privateConstructorUsedError;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatStateCopyWith<ChatState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
  @useResult
  $Res call({
    Planet selectedPlanet,
    List<Conversation> conversations,
    Conversation? activeConversation,
    List<ChatMessage> messages,
    bool isStreaming,
    int remainingQuota,
    String? lastFailedPrompt,
    String? streamError,
  });

  $PlanetCopyWith<$Res> get selectedPlanet;
  $ConversationCopyWith<$Res>? get activeConversation;
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedPlanet = null,
    Object? conversations = null,
    Object? activeConversation = freezed,
    Object? messages = null,
    Object? isStreaming = null,
    Object? remainingQuota = null,
    Object? lastFailedPrompt = freezed,
    Object? streamError = freezed,
  }) {
    return _then(
      _value.copyWith(
            selectedPlanet: null == selectedPlanet
                ? _value.selectedPlanet
                : selectedPlanet // ignore: cast_nullable_to_non_nullable
                      as Planet,
            conversations: null == conversations
                ? _value.conversations
                : conversations // ignore: cast_nullable_to_non_nullable
                      as List<Conversation>,
            activeConversation: freezed == activeConversation
                ? _value.activeConversation
                : activeConversation // ignore: cast_nullable_to_non_nullable
                      as Conversation?,
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<ChatMessage>,
            isStreaming: null == isStreaming
                ? _value.isStreaming
                : isStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            remainingQuota: null == remainingQuota
                ? _value.remainingQuota
                : remainingQuota // ignore: cast_nullable_to_non_nullable
                      as int,
            lastFailedPrompt: freezed == lastFailedPrompt
                ? _value.lastFailedPrompt
                : lastFailedPrompt // ignore: cast_nullable_to_non_nullable
                      as String?,
            streamError: freezed == streamError
                ? _value.streamError
                : streamError // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlanetCopyWith<$Res> get selectedPlanet {
    return $PlanetCopyWith<$Res>(_value.selectedPlanet, (value) {
      return _then(_value.copyWith(selectedPlanet: value) as $Val);
    });
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConversationCopyWith<$Res>? get activeConversation {
    if (_value.activeConversation == null) {
      return null;
    }

    return $ConversationCopyWith<$Res>(_value.activeConversation!, (value) {
      return _then(_value.copyWith(activeConversation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatStateImplCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$$ChatStateImplCopyWith(
    _$ChatStateImpl value,
    $Res Function(_$ChatStateImpl) then,
  ) = __$$ChatStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Planet selectedPlanet,
    List<Conversation> conversations,
    Conversation? activeConversation,
    List<ChatMessage> messages,
    bool isStreaming,
    int remainingQuota,
    String? lastFailedPrompt,
    String? streamError,
  });

  @override
  $PlanetCopyWith<$Res> get selectedPlanet;
  @override
  $ConversationCopyWith<$Res>? get activeConversation;
}

/// @nodoc
class __$$ChatStateImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateImpl>
    implements _$$ChatStateImplCopyWith<$Res> {
  __$$ChatStateImplCopyWithImpl(
    _$ChatStateImpl _value,
    $Res Function(_$ChatStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedPlanet = null,
    Object? conversations = null,
    Object? activeConversation = freezed,
    Object? messages = null,
    Object? isStreaming = null,
    Object? remainingQuota = null,
    Object? lastFailedPrompt = freezed,
    Object? streamError = freezed,
  }) {
    return _then(
      _$ChatStateImpl(
        selectedPlanet: null == selectedPlanet
            ? _value.selectedPlanet
            : selectedPlanet // ignore: cast_nullable_to_non_nullable
                  as Planet,
        conversations: null == conversations
            ? _value._conversations
            : conversations // ignore: cast_nullable_to_non_nullable
                  as List<Conversation>,
        activeConversation: freezed == activeConversation
            ? _value.activeConversation
            : activeConversation // ignore: cast_nullable_to_non_nullable
                  as Conversation?,
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<ChatMessage>,
        isStreaming: null == isStreaming
            ? _value.isStreaming
            : isStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        remainingQuota: null == remainingQuota
            ? _value.remainingQuota
            : remainingQuota // ignore: cast_nullable_to_non_nullable
                  as int,
        lastFailedPrompt: freezed == lastFailedPrompt
            ? _value.lastFailedPrompt
            : lastFailedPrompt // ignore: cast_nullable_to_non_nullable
                  as String?,
        streamError: freezed == streamError
            ? _value.streamError
            : streamError // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ChatStateImpl implements _ChatState {
  const _$ChatStateImpl({
    required this.selectedPlanet,
    final List<Conversation> conversations = const [],
    this.activeConversation,
    final List<ChatMessage> messages = const [],
    this.isStreaming = false,
    this.remainingQuota = 50,
    this.lastFailedPrompt,
    this.streamError,
  }) : _conversations = conversations,
       _messages = messages;

  @override
  final Planet selectedPlanet;
  final List<Conversation> _conversations;
  @override
  @JsonKey()
  List<Conversation> get conversations {
    if (_conversations is EqualUnmodifiableListView) return _conversations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conversations);
  }

  @override
  final Conversation? activeConversation;
  final List<ChatMessage> _messages;
  @override
  @JsonKey()
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final bool isStreaming;
  @override
  @JsonKey()
  final int remainingQuota;
  @override
  final String? lastFailedPrompt;
  @override
  final String? streamError;

  @override
  String toString() {
    return 'ChatState(selectedPlanet: $selectedPlanet, conversations: $conversations, activeConversation: $activeConversation, messages: $messages, isStreaming: $isStreaming, remainingQuota: $remainingQuota, lastFailedPrompt: $lastFailedPrompt, streamError: $streamError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateImpl &&
            (identical(other.selectedPlanet, selectedPlanet) ||
                other.selectedPlanet == selectedPlanet) &&
            const DeepCollectionEquality().equals(
              other._conversations,
              _conversations,
            ) &&
            (identical(other.activeConversation, activeConversation) ||
                other.activeConversation == activeConversation) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.remainingQuota, remainingQuota) ||
                other.remainingQuota == remainingQuota) &&
            (identical(other.lastFailedPrompt, lastFailedPrompt) ||
                other.lastFailedPrompt == lastFailedPrompt) &&
            (identical(other.streamError, streamError) ||
                other.streamError == streamError));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedPlanet,
    const DeepCollectionEquality().hash(_conversations),
    activeConversation,
    const DeepCollectionEquality().hash(_messages),
    isStreaming,
    remainingQuota,
    lastFailedPrompt,
    streamError,
  );

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      __$$ChatStateImplCopyWithImpl<_$ChatStateImpl>(this, _$identity);
}

abstract class _ChatState implements ChatState {
  const factory _ChatState({
    required final Planet selectedPlanet,
    final List<Conversation> conversations,
    final Conversation? activeConversation,
    final List<ChatMessage> messages,
    final bool isStreaming,
    final int remainingQuota,
    final String? lastFailedPrompt,
    final String? streamError,
  }) = _$ChatStateImpl;

  @override
  Planet get selectedPlanet;
  @override
  List<Conversation> get conversations;
  @override
  Conversation? get activeConversation;
  @override
  List<ChatMessage> get messages;
  @override
  bool get isStreaming;
  @override
  int get remainingQuota;
  @override
  String? get lastFailedPrompt;
  @override
  String? get streamError;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
