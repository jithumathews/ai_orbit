import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../chat/domain/models/ai_model.dart';

part 'observatory_telemetry.freezed.dart';
part 'observatory_telemetry.g.dart';

@freezed
class UserQuota with _$UserQuota {
  const factory UserQuota({
    @JsonKey(name: 'daily_count') @Default(0) int dailyCount,
    @JsonKey(name: 'daily_limit') @Default(50) int dailyLimit,
    @Default(50) int remaining,
    @JsonKey(name: 'token_count') @Default(0) int tokenCount,
    @Default('') String period,
  }) = _UserQuota;

  factory UserQuota.fromJson(Map<String, dynamic> json) => _$UserQuotaFromJson(json);

  static UserQuota fallback() => UserQuota(
    dailyCount: 3,
    dailyLimit: 50,
    remaining: 47,
    tokenCount: 1420,
    period: DateTime.now().toIso8601String().substring(0, 10),
  );
}

@freezed
class ObservatoryTelemetry with _$ObservatoryTelemetry {
  const factory ObservatoryTelemetry({
    @Default([]) List<AiModel> models,
    required UserQuota quota,
  }) = _ObservatoryTelemetry;

  factory ObservatoryTelemetry.fromJson(Map<String, dynamic> json) =>
      _$ObservatoryTelemetryFromJson(json);
}
