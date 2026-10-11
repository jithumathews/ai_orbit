// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AiModel _$AiModelFromJson(Map<String, dynamic> json) {
  return _AiModel.fromJson(json);
}

/// @nodoc
mixin _$AiModel {
  String get id => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  @JsonKey(name: 'model_id')
  String get modelId => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;
  List<String> get capabilities => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_output_tokens')
  int get maxOutputTokens => throw _privateConstructorUsedError;
  @JsonKey(name: 'context_window')
  int get contextWindow => throw _privateConstructorUsedError;
  @JsonKey(name: 'rpm_limit')
  int get rpmLimit => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_limit')
  int get dailyLimit => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'healthy', 'degraded', 'cooldown', 'disabled'
  @JsonKey(name: 'avg_latency_ms')
  int get avgLatencyMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_rate')
  double get errorRate => throw _privateConstructorUsedError;

  /// Serializes this AiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiModelCopyWith<AiModel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiModelCopyWith<$Res> {
  factory $AiModelCopyWith(AiModel value, $Res Function(AiModel) then) =
      _$AiModelCopyWithImpl<$Res, AiModel>;
  @useResult
  $Res call({
    String id,
    String provider,
    @JsonKey(name: 'model_id') String modelId,
    @JsonKey(name: 'display_name') String displayName,
    List<String> capabilities,
    @JsonKey(name: 'max_output_tokens') int maxOutputTokens,
    @JsonKey(name: 'context_window') int contextWindow,
    @JsonKey(name: 'rpm_limit') int rpmLimit,
    @JsonKey(name: 'daily_limit') int dailyLimit,
    bool enabled,
    int priority,
    String status,
    @JsonKey(name: 'avg_latency_ms') int avgLatencyMs,
    @JsonKey(name: 'error_rate') double errorRate,
  });
}

/// @nodoc
class _$AiModelCopyWithImpl<$Res, $Val extends AiModel>
    implements $AiModelCopyWith<$Res> {
  _$AiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? provider = null,
    Object? modelId = null,
    Object? displayName = null,
    Object? capabilities = null,
    Object? maxOutputTokens = null,
    Object? contextWindow = null,
    Object? rpmLimit = null,
    Object? dailyLimit = null,
    Object? enabled = null,
    Object? priority = null,
    Object? status = null,
    Object? avgLatencyMs = null,
    Object? errorRate = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            modelId: null == modelId
                ? _value.modelId
                : modelId // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            capabilities: null == capabilities
                ? _value.capabilities
                : capabilities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            maxOutputTokens: null == maxOutputTokens
                ? _value.maxOutputTokens
                : maxOutputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            contextWindow: null == contextWindow
                ? _value.contextWindow
                : contextWindow // ignore: cast_nullable_to_non_nullable
                      as int,
            rpmLimit: null == rpmLimit
                ? _value.rpmLimit
                : rpmLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyLimit: null == dailyLimit
                ? _value.dailyLimit
                : dailyLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            avgLatencyMs: null == avgLatencyMs
                ? _value.avgLatencyMs
                : avgLatencyMs // ignore: cast_nullable_to_non_nullable
                      as int,
            errorRate: null == errorRate
                ? _value.errorRate
                : errorRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiModelImplCopyWith<$Res> implements $AiModelCopyWith<$Res> {
  factory _$$AiModelImplCopyWith(
    _$AiModelImpl value,
    $Res Function(_$AiModelImpl) then,
  ) = __$$AiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String provider,
    @JsonKey(name: 'model_id') String modelId,
    @JsonKey(name: 'display_name') String displayName,
    List<String> capabilities,
    @JsonKey(name: 'max_output_tokens') int maxOutputTokens,
    @JsonKey(name: 'context_window') int contextWindow,
    @JsonKey(name: 'rpm_limit') int rpmLimit,
    @JsonKey(name: 'daily_limit') int dailyLimit,
    bool enabled,
    int priority,
    String status,
    @JsonKey(name: 'avg_latency_ms') int avgLatencyMs,
    @JsonKey(name: 'error_rate') double errorRate,
  });
}

/// @nodoc
class __$$AiModelImplCopyWithImpl<$Res>
    extends _$AiModelCopyWithImpl<$Res, _$AiModelImpl>
    implements _$$AiModelImplCopyWith<$Res> {
  __$$AiModelImplCopyWithImpl(
    _$AiModelImpl _value,
    $Res Function(_$AiModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? provider = null,
    Object? modelId = null,
    Object? displayName = null,
    Object? capabilities = null,
    Object? maxOutputTokens = null,
    Object? contextWindow = null,
    Object? rpmLimit = null,
    Object? dailyLimit = null,
    Object? enabled = null,
    Object? priority = null,
    Object? status = null,
    Object? avgLatencyMs = null,
    Object? errorRate = null,
  }) {
    return _then(
      _$AiModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        modelId: null == modelId
            ? _value.modelId
            : modelId // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        capabilities: null == capabilities
            ? _value._capabilities
            : capabilities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        maxOutputTokens: null == maxOutputTokens
            ? _value.maxOutputTokens
            : maxOutputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        contextWindow: null == contextWindow
            ? _value.contextWindow
            : contextWindow // ignore: cast_nullable_to_non_nullable
                  as int,
        rpmLimit: null == rpmLimit
            ? _value.rpmLimit
            : rpmLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyLimit: null == dailyLimit
            ? _value.dailyLimit
            : dailyLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        avgLatencyMs: null == avgLatencyMs
            ? _value.avgLatencyMs
            : avgLatencyMs // ignore: cast_nullable_to_non_nullable
                  as int,
        errorRate: null == errorRate
            ? _value.errorRate
            : errorRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiModelImpl implements _AiModel {
  const _$AiModelImpl({
    required this.id,
    required this.provider,
    @JsonKey(name: 'model_id') required this.modelId,
    @JsonKey(name: 'display_name') required this.displayName,
    final List<String> capabilities = const [],
    @JsonKey(name: 'max_output_tokens') this.maxOutputTokens = 4096,
    @JsonKey(name: 'context_window') this.contextWindow = 128000,
    @JsonKey(name: 'rpm_limit') this.rpmLimit = 30,
    @JsonKey(name: 'daily_limit') this.dailyLimit = 500,
    this.enabled = true,
    this.priority = 1,
    this.status = 'healthy',
    @JsonKey(name: 'avg_latency_ms') this.avgLatencyMs = 0,
    @JsonKey(name: 'error_rate') this.errorRate = 0.0,
  }) : _capabilities = capabilities;

  factory _$AiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiModelImplFromJson(json);

  @override
  final String id;
  @override
  final String provider;
  @override
  @JsonKey(name: 'model_id')
  final String modelId;
  @override
  @JsonKey(name: 'display_name')
  final String displayName;
  final List<String> _capabilities;
  @override
  @JsonKey()
  List<String> get capabilities {
    if (_capabilities is EqualUnmodifiableListView) return _capabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_capabilities);
  }

  @override
  @JsonKey(name: 'max_output_tokens')
  final int maxOutputTokens;
  @override
  @JsonKey(name: 'context_window')
  final int contextWindow;
  @override
  @JsonKey(name: 'rpm_limit')
  final int rpmLimit;
  @override
  @JsonKey(name: 'daily_limit')
  final int dailyLimit;
  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey()
  final int priority;
  @override
  @JsonKey()
  final String status;
  // 'healthy', 'degraded', 'cooldown', 'disabled'
  @override
  @JsonKey(name: 'avg_latency_ms')
  final int avgLatencyMs;
  @override
  @JsonKey(name: 'error_rate')
  final double errorRate;

  @override
  String toString() {
    return 'AiModel(id: $id, provider: $provider, modelId: $modelId, displayName: $displayName, capabilities: $capabilities, maxOutputTokens: $maxOutputTokens, contextWindow: $contextWindow, rpmLimit: $rpmLimit, dailyLimit: $dailyLimit, enabled: $enabled, priority: $priority, status: $status, avgLatencyMs: $avgLatencyMs, errorRate: $errorRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            const DeepCollectionEquality().equals(
              other._capabilities,
              _capabilities,
            ) &&
            (identical(other.maxOutputTokens, maxOutputTokens) ||
                other.maxOutputTokens == maxOutputTokens) &&
            (identical(other.contextWindow, contextWindow) ||
                other.contextWindow == contextWindow) &&
            (identical(other.rpmLimit, rpmLimit) ||
                other.rpmLimit == rpmLimit) &&
            (identical(other.dailyLimit, dailyLimit) ||
                other.dailyLimit == dailyLimit) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.avgLatencyMs, avgLatencyMs) ||
                other.avgLatencyMs == avgLatencyMs) &&
            (identical(other.errorRate, errorRate) ||
                other.errorRate == errorRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    provider,
    modelId,
    displayName,
    const DeepCollectionEquality().hash(_capabilities),
    maxOutputTokens,
    contextWindow,
    rpmLimit,
    dailyLimit,
    enabled,
    priority,
    status,
    avgLatencyMs,
    errorRate,
  );

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiModelImplCopyWith<_$AiModelImpl> get copyWith =>
      __$$AiModelImplCopyWithImpl<_$AiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiModelImplToJson(this);
  }
}

abstract class _AiModel implements AiModel {
  const factory _AiModel({
    required final String id,
    required final String provider,
    @JsonKey(name: 'model_id') required final String modelId,
    @JsonKey(name: 'display_name') required final String displayName,
    final List<String> capabilities,
    @JsonKey(name: 'max_output_tokens') final int maxOutputTokens,
    @JsonKey(name: 'context_window') final int contextWindow,
    @JsonKey(name: 'rpm_limit') final int rpmLimit,
    @JsonKey(name: 'daily_limit') final int dailyLimit,
    final bool enabled,
    final int priority,
    final String status,
    @JsonKey(name: 'avg_latency_ms') final int avgLatencyMs,
    @JsonKey(name: 'error_rate') final double errorRate,
  }) = _$AiModelImpl;

  factory _AiModel.fromJson(Map<String, dynamic> json) = _$AiModelImpl.fromJson;

  @override
  String get id;
  @override
  String get provider;
  @override
  @JsonKey(name: 'model_id')
  String get modelId;
  @override
  @JsonKey(name: 'display_name')
  String get displayName;
  @override
  List<String> get capabilities;
  @override
  @JsonKey(name: 'max_output_tokens')
  int get maxOutputTokens;
  @override
  @JsonKey(name: 'context_window')
  int get contextWindow;
  @override
  @JsonKey(name: 'rpm_limit')
  int get rpmLimit;
  @override
  @JsonKey(name: 'daily_limit')
  int get dailyLimit;
  @override
  bool get enabled;
  @override
  int get priority;
  @override
  String get status; // 'healthy', 'degraded', 'cooldown', 'disabled'
  @override
  @JsonKey(name: 'avg_latency_ms')
  int get avgLatencyMs;
  @override
  @JsonKey(name: 'error_rate')
  double get errorRate;

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiModelImplCopyWith<_$AiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
