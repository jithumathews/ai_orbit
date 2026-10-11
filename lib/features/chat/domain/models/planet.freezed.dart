// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Planet {
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get planetTitle => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  IconData get icon => throw _privateConstructorUsedError;
  Color get primaryColor => throw _privateConstructorUsedError;
  List<Color> get gradient => throw _privateConstructorUsedError;
  bool get isComingSoon => throw _privateConstructorUsedError;
  double get defaultTemperature => throw _privateConstructorUsedError;

  /// Create a copy of Planet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanetCopyWith<Planet> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanetCopyWith<$Res> {
  factory $PlanetCopyWith(Planet value, $Res Function(Planet) then) =
      _$PlanetCopyWithImpl<$Res, Planet>;
  @useResult
  $Res call({
    String slug,
    String name,
    String planetTitle,
    String description,
    IconData icon,
    Color primaryColor,
    List<Color> gradient,
    bool isComingSoon,
    double defaultTemperature,
  });
}

/// @nodoc
class _$PlanetCopyWithImpl<$Res, $Val extends Planet>
    implements $PlanetCopyWith<$Res> {
  _$PlanetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Planet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? planetTitle = null,
    Object? description = null,
    Object? icon = null,
    Object? primaryColor = null,
    Object? gradient = null,
    Object? isComingSoon = null,
    Object? defaultTemperature = null,
  }) {
    return _then(
      _value.copyWith(
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            planetTitle: null == planetTitle
                ? _value.planetTitle
                : planetTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
            primaryColor: null == primaryColor
                ? _value.primaryColor
                : primaryColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            gradient: null == gradient
                ? _value.gradient
                : gradient // ignore: cast_nullable_to_non_nullable
                      as List<Color>,
            isComingSoon: null == isComingSoon
                ? _value.isComingSoon
                : isComingSoon // ignore: cast_nullable_to_non_nullable
                      as bool,
            defaultTemperature: null == defaultTemperature
                ? _value.defaultTemperature
                : defaultTemperature // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanetImplCopyWith<$Res> implements $PlanetCopyWith<$Res> {
  factory _$$PlanetImplCopyWith(
    _$PlanetImpl value,
    $Res Function(_$PlanetImpl) then,
  ) = __$$PlanetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String slug,
    String name,
    String planetTitle,
    String description,
    IconData icon,
    Color primaryColor,
    List<Color> gradient,
    bool isComingSoon,
    double defaultTemperature,
  });
}

/// @nodoc
class __$$PlanetImplCopyWithImpl<$Res>
    extends _$PlanetCopyWithImpl<$Res, _$PlanetImpl>
    implements _$$PlanetImplCopyWith<$Res> {
  __$$PlanetImplCopyWithImpl(
    _$PlanetImpl _value,
    $Res Function(_$PlanetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Planet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? name = null,
    Object? planetTitle = null,
    Object? description = null,
    Object? icon = null,
    Object? primaryColor = null,
    Object? gradient = null,
    Object? isComingSoon = null,
    Object? defaultTemperature = null,
  }) {
    return _then(
      _$PlanetImpl(
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        planetTitle: null == planetTitle
            ? _value.planetTitle
            : planetTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
        primaryColor: null == primaryColor
            ? _value.primaryColor
            : primaryColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        gradient: null == gradient
            ? _value._gradient
            : gradient // ignore: cast_nullable_to_non_nullable
                  as List<Color>,
        isComingSoon: null == isComingSoon
            ? _value.isComingSoon
            : isComingSoon // ignore: cast_nullable_to_non_nullable
                  as bool,
        defaultTemperature: null == defaultTemperature
            ? _value.defaultTemperature
            : defaultTemperature // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$PlanetImpl extends _Planet {
  const _$PlanetImpl({
    required this.slug,
    required this.name,
    required this.planetTitle,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required final List<Color> gradient,
    this.isComingSoon = false,
    this.defaultTemperature = 0.7,
  }) : _gradient = gradient,
       super._();

  @override
  final String slug;
  @override
  final String name;
  @override
  final String planetTitle;
  @override
  final String description;
  @override
  final IconData icon;
  @override
  final Color primaryColor;
  final List<Color> _gradient;
  @override
  List<Color> get gradient {
    if (_gradient is EqualUnmodifiableListView) return _gradient;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gradient);
  }

  @override
  @JsonKey()
  final bool isComingSoon;
  @override
  @JsonKey()
  final double defaultTemperature;

  @override
  String toString() {
    return 'Planet(slug: $slug, name: $name, planetTitle: $planetTitle, description: $description, icon: $icon, primaryColor: $primaryColor, gradient: $gradient, isComingSoon: $isComingSoon, defaultTemperature: $defaultTemperature)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanetImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.planetTitle, planetTitle) ||
                other.planetTitle == planetTitle) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            const DeepCollectionEquality().equals(other._gradient, _gradient) &&
            (identical(other.isComingSoon, isComingSoon) ||
                other.isComingSoon == isComingSoon) &&
            (identical(other.defaultTemperature, defaultTemperature) ||
                other.defaultTemperature == defaultTemperature));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    slug,
    name,
    planetTitle,
    description,
    icon,
    primaryColor,
    const DeepCollectionEquality().hash(_gradient),
    isComingSoon,
    defaultTemperature,
  );

  /// Create a copy of Planet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanetImplCopyWith<_$PlanetImpl> get copyWith =>
      __$$PlanetImplCopyWithImpl<_$PlanetImpl>(this, _$identity);
}

abstract class _Planet extends Planet {
  const factory _Planet({
    required final String slug,
    required final String name,
    required final String planetTitle,
    required final String description,
    required final IconData icon,
    required final Color primaryColor,
    required final List<Color> gradient,
    final bool isComingSoon,
    final double defaultTemperature,
  }) = _$PlanetImpl;
  const _Planet._() : super._();

  @override
  String get slug;
  @override
  String get name;
  @override
  String get planetTitle;
  @override
  String get description;
  @override
  IconData get icon;
  @override
  Color get primaryColor;
  @override
  List<Color> get gradient;
  @override
  bool get isComingSoon;
  @override
  double get defaultTemperature;

  /// Create a copy of Planet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanetImplCopyWith<_$PlanetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
