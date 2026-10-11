// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'observatory_telemetry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserQuota _$UserQuotaFromJson(Map<String, dynamic> json) {
  return _UserQuota.fromJson(json);
}

/// @nodoc
mixin _$UserQuota {
  @JsonKey(name: 'daily_count')
  int get dailyCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_limit')
  int get dailyLimit => throw _privateConstructorUsedError;
  int get remaining => throw _privateConstructorUsedError;
  @JsonKey(name: 'token_count')
  int get tokenCount => throw _privateConstructorUsedError;
  String get period => throw _privateConstructorUsedError;

  /// Serializes this UserQuota to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserQuota
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserQuotaCopyWith<UserQuota> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserQuotaCopyWith<$Res> {
  factory $UserQuotaCopyWith(UserQuota value, $Res Function(UserQuota) then) =
      _$UserQuotaCopyWithImpl<$Res, UserQuota>;
  @useResult
  $Res call({
    @JsonKey(name: 'daily_count') int dailyCount,
    @JsonKey(name: 'daily_limit') int dailyLimit,
    int remaining,
    @JsonKey(name: 'token_count') int tokenCount,
    String period,
  });
}

/// @nodoc
class _$UserQuotaCopyWithImpl<$Res, $Val extends UserQuota>
    implements $UserQuotaCopyWith<$Res> {
  _$UserQuotaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserQuota
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyCount = null,
    Object? dailyLimit = null,
    Object? remaining = null,
    Object? tokenCount = null,
    Object? period = null,
  }) {
    return _then(
      _value.copyWith(
            dailyCount: null == dailyCount
                ? _value.dailyCount
                : dailyCount // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyLimit: null == dailyLimit
                ? _value.dailyLimit
                : dailyLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            remaining: null == remaining
                ? _value.remaining
                : remaining // ignore: cast_nullable_to_non_nullable
                      as int,
            tokenCount: null == tokenCount
                ? _value.tokenCount
                : tokenCount // ignore: cast_nullable_to_non_nullable
                      as int,
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserQuotaImplCopyWith<$Res>
    implements $UserQuotaCopyWith<$Res> {
  factory _$$UserQuotaImplCopyWith(
    _$UserQuotaImpl value,
    $Res Function(_$UserQuotaImpl) then,
  ) = __$$UserQuotaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'daily_count') int dailyCount,
    @JsonKey(name: 'daily_limit') int dailyLimit,
    int remaining,
    @JsonKey(name: 'token_count') int tokenCount,
    String period,
  });
}

/// @nodoc
class __$$UserQuotaImplCopyWithImpl<$Res>
    extends _$UserQuotaCopyWithImpl<$Res, _$UserQuotaImpl>
    implements _$$UserQuotaImplCopyWith<$Res> {
  __$$UserQuotaImplCopyWithImpl(
    _$UserQuotaImpl _value,
    $Res Function(_$UserQuotaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserQuota
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyCount = null,
    Object? dailyLimit = null,
    Object? remaining = null,
    Object? tokenCount = null,
    Object? period = null,
  }) {
    return _then(
      _$UserQuotaImpl(
        dailyCount: null == dailyCount
            ? _value.dailyCount
            : dailyCount // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyLimit: null == dailyLimit
            ? _value.dailyLimit
            : dailyLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        remaining: null == remaining
            ? _value.remaining
            : remaining // ignore: cast_nullable_to_non_nullable
                  as int,
        tokenCount: null == tokenCount
            ? _value.tokenCount
            : tokenCount // ignore: cast_nullable_to_non_nullable
                  as int,
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserQuotaImpl implements _UserQuota {
  const _$UserQuotaImpl({
    @JsonKey(name: 'daily_count') this.dailyCount = 0,
    @JsonKey(name: 'daily_limit') this.dailyLimit = 50,
    this.remaining = 50,
    @JsonKey(name: 'token_count') this.tokenCount = 0,
    this.period = '',
  });

  factory _$UserQuotaImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserQuotaImplFromJson(json);

  @override
  @JsonKey(name: 'daily_count')
  final int dailyCount;
  @override
  @JsonKey(name: 'daily_limit')
  final int dailyLimit;
  @override
  @JsonKey()
  final int remaining;
  @override
  @JsonKey(name: 'token_count')
  final int tokenCount;
  @override
  @JsonKey()
  final String period;

  @override
  String toString() {
    return 'UserQuota(dailyCount: $dailyCount, dailyLimit: $dailyLimit, remaining: $remaining, tokenCount: $tokenCount, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserQuotaImpl &&
            (identical(other.dailyCount, dailyCount) ||
                other.dailyCount == dailyCount) &&
            (identical(other.dailyLimit, dailyLimit) ||
                other.dailyLimit == dailyLimit) &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.tokenCount, tokenCount) ||
                other.tokenCount == tokenCount) &&
            (identical(other.period, period) || other.period == period));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dailyCount,
    dailyLimit,
    remaining,
    tokenCount,
    period,
  );

  /// Create a copy of UserQuota
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserQuotaImplCopyWith<_$UserQuotaImpl> get copyWith =>
      __$$UserQuotaImplCopyWithImpl<_$UserQuotaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserQuotaImplToJson(this);
  }
}

abstract class _UserQuota implements UserQuota {
  const factory _UserQuota({
    @JsonKey(name: 'daily_count') final int dailyCount,
    @JsonKey(name: 'daily_limit') final int dailyLimit,
    final int remaining,
    @JsonKey(name: 'token_count') final int tokenCount,
    final String period,
  }) = _$UserQuotaImpl;

  factory _UserQuota.fromJson(Map<String, dynamic> json) =
      _$UserQuotaImpl.fromJson;

  @override
  @JsonKey(name: 'daily_count')
  int get dailyCount;
  @override
  @JsonKey(name: 'daily_limit')
  int get dailyLimit;
  @override
  int get remaining;
  @override
  @JsonKey(name: 'token_count')
  int get tokenCount;
  @override
  String get period;

  /// Create a copy of UserQuota
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserQuotaImplCopyWith<_$UserQuotaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ObservatoryTelemetry _$ObservatoryTelemetryFromJson(Map<String, dynamic> json) {
  return _ObservatoryTelemetry.fromJson(json);
}

/// @nodoc
mixin _$ObservatoryTelemetry {
  List<AiModel> get models => throw _privateConstructorUsedError;
  UserQuota get quota => throw _privateConstructorUsedError;

  /// Serializes this ObservatoryTelemetry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ObservatoryTelemetry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ObservatoryTelemetryCopyWith<ObservatoryTelemetry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ObservatoryTelemetryCopyWith<$Res> {
  factory $ObservatoryTelemetryCopyWith(
    ObservatoryTelemetry value,
    $Res Function(ObservatoryTelemetry) then,
  ) = _$ObservatoryTelemetryCopyWithImpl<$Res, ObservatoryTelemetry>;
  @useResult
  $Res call({List<AiModel> models, UserQuota quota});

  $UserQuotaCopyWith<$Res> get quota;
}

/// @nodoc
class _$ObservatoryTelemetryCopyWithImpl<
  $Res,
  $Val extends ObservatoryTelemetry
>
    implements $ObservatoryTelemetryCopyWith<$Res> {
  _$ObservatoryTelemetryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ObservatoryTelemetry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? models = null, Object? quota = null}) {
    return _then(
      _value.copyWith(
            models: null == models
                ? _value.models
                : models // ignore: cast_nullable_to_non_nullable
                      as List<AiModel>,
            quota: null == quota
                ? _value.quota
                : quota // ignore: cast_nullable_to_non_nullable
                      as UserQuota,
          )
          as $Val,
    );
  }

  /// Create a copy of ObservatoryTelemetry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserQuotaCopyWith<$Res> get quota {
    return $UserQuotaCopyWith<$Res>(_value.quota, (value) {
      return _then(_value.copyWith(quota: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ObservatoryTelemetryImplCopyWith<$Res>
    implements $ObservatoryTelemetryCopyWith<$Res> {
  factory _$$ObservatoryTelemetryImplCopyWith(
    _$ObservatoryTelemetryImpl value,
    $Res Function(_$ObservatoryTelemetryImpl) then,
  ) = __$$ObservatoryTelemetryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AiModel> models, UserQuota quota});

  @override
  $UserQuotaCopyWith<$Res> get quota;
}

/// @nodoc
class __$$ObservatoryTelemetryImplCopyWithImpl<$Res>
    extends _$ObservatoryTelemetryCopyWithImpl<$Res, _$ObservatoryTelemetryImpl>
    implements _$$ObservatoryTelemetryImplCopyWith<$Res> {
  __$$ObservatoryTelemetryImplCopyWithImpl(
    _$ObservatoryTelemetryImpl _value,
    $Res Function(_$ObservatoryTelemetryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ObservatoryTelemetry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? models = null, Object? quota = null}) {
    return _then(
      _$ObservatoryTelemetryImpl(
        models: null == models
            ? _value._models
            : models // ignore: cast_nullable_to_non_nullable
                  as List<AiModel>,
        quota: null == quota
            ? _value.quota
            : quota // ignore: cast_nullable_to_non_nullable
                  as UserQuota,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ObservatoryTelemetryImpl implements _ObservatoryTelemetry {
  const _$ObservatoryTelemetryImpl({
    final List<AiModel> models = const [],
    required this.quota,
  }) : _models = models;

  factory _$ObservatoryTelemetryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ObservatoryTelemetryImplFromJson(json);

  final List<AiModel> _models;
  @override
  @JsonKey()
  List<AiModel> get models {
    if (_models is EqualUnmodifiableListView) return _models;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_models);
  }

  @override
  final UserQuota quota;

  @override
  String toString() {
    return 'ObservatoryTelemetry(models: $models, quota: $quota)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ObservatoryTelemetryImpl &&
            const DeepCollectionEquality().equals(other._models, _models) &&
            (identical(other.quota, quota) || other.quota == quota));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_models),
    quota,
  );

  /// Create a copy of ObservatoryTelemetry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ObservatoryTelemetryImplCopyWith<_$ObservatoryTelemetryImpl>
  get copyWith =>
      __$$ObservatoryTelemetryImplCopyWithImpl<_$ObservatoryTelemetryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ObservatoryTelemetryImplToJson(this);
  }
}

abstract class _ObservatoryTelemetry implements ObservatoryTelemetry {
  const factory _ObservatoryTelemetry({
    final List<AiModel> models,
    required final UserQuota quota,
  }) = _$ObservatoryTelemetryImpl;

  factory _ObservatoryTelemetry.fromJson(Map<String, dynamic> json) =
      _$ObservatoryTelemetryImpl.fromJson;

  @override
  List<AiModel> get models;
  @override
  UserQuota get quota;

  /// Create a copy of ObservatoryTelemetry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ObservatoryTelemetryImplCopyWith<_$ObservatoryTelemetryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
