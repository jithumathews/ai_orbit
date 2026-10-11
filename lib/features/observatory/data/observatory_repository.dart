import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/orbit_config.dart';
import '../../auth/data/auth_repository.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/domain/models/ai_model.dart';
import '../domain/models/observatory_telemetry.dart';

final observatoryRepositoryProvider = Provider<ObservatoryRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final chatRepo = ref.watch(chatRepositoryProvider);
  return ObservatoryRepository(authRepo, chatRepo);
});

class ObservatoryRepository {
  final AuthRepository _auth;
  final ChatRepository _chat;

  ObservatoryRepository(this._auth, this._chat);

  Future<ObservatoryTelemetry> getTelemetry() async {
    if (_auth.isMockMode || !OrbitConfig.isConfigured) {
      return ObservatoryTelemetry(
        models: AiModel.defaultModels(),
        quota: UserQuota.fallback(),
      );
    }

    try {
      final token = _auth.jwtToken;
      final url = '${OrbitConfig.supabaseUrl}/functions/v1/model-status';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'apikey': OrbitConfig.supabaseAnonKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final modelsRaw = data['models'] as List<dynamic>? ?? [];
        final quotaRaw = data['user_quota'] as Map<String, dynamic>? ?? {};

        final models = modelsRaw
            .map((m) => AiModel.fromJson(m as Map<String, dynamic>))
            .toList();

        final quota = UserQuota.fromJson(quotaRaw);

        return ObservatoryTelemetry(models: models, quota: quota);
      }
    } catch (e) {
      debugPrint('[ObservatoryRepository] Failed to fetch remote telemetry: $e');
    }

    return ObservatoryTelemetry(
      models: await _chat.getEnabledModels(),
      quota: UserQuota.fallback(),
    );
  }
}
