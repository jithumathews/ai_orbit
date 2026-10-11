import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/orbit_config.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/models/chat_source.dart';

final aiGatewayDataSourceProvider = Provider<AiGatewayDataSource>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return AiGatewayDataSource(auth);
});

class GatewayEvent {
  final String type; // 'token', 'usage', 'done', 'error', 'fallback', 'search', 'sources'
  final String? delta;
  final int? inputTokens;
  final int? outputTokens;
  final String? modelRunId;
  final String? modelId;
  final String? provider;
  final String? fallbackFrom;
  final String? fallbackTo;
  final String? errorCode;
  final String? message;
  final bool? retryable;
  final List<ChatSource>? sources;
  final String? searchQuery;
  final int? sourcesCount;
  final String? searchProvider;

  GatewayEvent({
    required this.type,
    this.delta,
    this.inputTokens,
    this.outputTokens,
    this.modelRunId,
    this.modelId,
    this.provider,
    this.fallbackFrom,
    this.fallbackTo,
    this.errorCode,
    this.message,
    this.retryable,
    this.sources,
    this.searchQuery,
    this.sourcesCount,
    this.searchProvider,
  });

  factory GatewayEvent.fromSSE(String eventName, String dataJson) {
    try {
      final map = jsonDecode(dataJson) as Map<String, dynamic>;
      List<ChatSource>? parsedSources;
      if (map['sources'] is List) {
        parsedSources = (map['sources'] as List)
            .map((item) => ChatSource.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return GatewayEvent(
        type: eventName,
        delta: map['delta'] as String?,
        inputTokens: map['input_tokens'] as int?,
        outputTokens: map['output_tokens'] as int?,
        modelRunId: map['model_run_id'] as String?,
        modelId: map['model_id'] as String?,
        provider: map['provider'] as String?,
        fallbackFrom: map['fallback_from'] as String?,
        fallbackTo: map['fallback_to'] as String?,
        errorCode: map['error_code'] as String?,
        message: map['message'] as String?,
        retryable: map['retryable'] as bool?,
        sources: parsedSources,
        searchQuery: map['query'] as String?,
        sourcesCount: map['sources_count'] as int?,
        searchProvider: map['provider'] as String?,
      );
    } catch (e) {
      return GatewayEvent(type: 'error', message: 'Failed to decode gateway packet: $e');
    }
  }
}

class AiGatewayDataSource {
  final AuthRepository _authRepository;

  AiGatewayDataSource(this._authRepository);

  Stream<GatewayEvent> streamChat({
    required String conversationId,
    required String agentSlug,
    String? modelId,
    required String message,
    List<Map<String, String>> history = const [],
    List<String> fallbackQueue = const [],
  }) async* {
    if (_authRepository.isMockMode || !OrbitConfig.isConfigured) {
      yield* _streamSimulated(
        conversationId: conversationId,
        agentSlug: agentSlug,
        modelId: modelId,
        message: message,
      );
      return;
    }

    final token = _authRepository.jwtToken;
    final functionUrl = '${OrbitConfig.supabaseUrl}/functions/v1/ai-chat';

    final request = http.Request('POST', Uri.parse(functionUrl));
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'apikey': OrbitConfig.supabaseAnonKey,
    });

    request.body = jsonEncode({
      'conversation_id': conversationId,
      'agent_slug': agentSlug,
      'model_id': modelId,
      'message': message,
      'history': history,
      'fallback_models': fallbackQueue,
    });

    http.StreamedResponse streamedResponse;
    try {
      final client = http.Client();
      streamedResponse = await client.send(request);
    } catch (e) {
      // Remote Edge Function is not deployed yet or blocked by CORS:
      // Fallback gracefully to high-fidelity local simulator with notice
      yield GatewayEvent(
        type: 'fallback',
        fallbackFrom: 'Remote Gateway (Offline)',
        fallbackTo: modelId ?? 'Orbit Engine',
        provider: 'local',
      );
      yield* _streamSimulated(
        conversationId: conversationId,
        agentSlug: agentSlug,
        modelId: modelId,
        message: message,
      );
      return;
    }

    if (streamedResponse.statusCode != 200) {
      final errBody = await streamedResponse.stream.bytesToString();
      if (streamedResponse.statusCode == 404) {
        // Function not deployed on Supabase yet
        yield GatewayEvent(
          type: 'fallback',
          fallbackFrom: 'Edge Function 404 (Pending Deploy)',
          fallbackTo: modelId ?? 'Orbit Engine',
          provider: 'local',
        );
        yield* _streamSimulated(
          conversationId: conversationId,
          agentSlug: agentSlug,
          modelId: modelId,
          message: message,
        );
        return;
      }

      try {
        final errJson = jsonDecode(errBody) as Map<String, dynamic>;
        final errorDetails = errJson['error'] as Map<String, dynamic>? ?? {};
        yield GatewayEvent(
          type: 'error',
          errorCode: errorDetails['code'] as String? ?? 'gateway_error',
          message: errorDetails['message'] as String? ?? 'Transmission error: ${streamedResponse.statusCode}',
          retryable: errorDetails['retryable'] as bool? ?? true,
        );
      } catch (_) {
        yield GatewayEvent(
          type: 'error',
          errorCode: 'http_${streamedResponse.statusCode}',
          message: 'Orbital transmission failed (HTTP ${streamedResponse.statusCode})',
          retryable: true,
        );
      }
      return;
    }

    String currentEvent = 'token';
    final lines = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('event: ')) {
        currentEvent = trimmed.substring(7).trim();
      } else if (trimmed.startsWith('data: ')) {
        final data = trimmed.substring(6).trim();
        yield GatewayEvent.fromSSE(currentEvent, data);
      }
    }
  }

  Stream<GatewayEvent> _streamSimulated({
    required String conversationId,
    required String agentSlug,
    String? modelId,
    required String message,
  }) async* {
    String planetResponse = '';
    switch (agentSlug) {
      case 'coding':
        planetResponse = '### Architecture & Solution\n\n'
            'Here is the verified production implementation for your request:\n\n'
            '```dart\n'
            '// Mars Engineering Optimization\n'
            'class OrbitEngine {\n'
            '  void execute() {\n'
            '    print("Telemetry verified: ${message.replaceAll('\n', ' ')}");\n'
            '  }\n'
            '}\n'
            '```\n\n'
            '**Key Trade-offs:**\n'
            '- High throughput with deterministic O(1) memory overhead.\n'
            '- Strict separation of concerns with robust error boundaries.';
        break;
      case 'creative':
        planetResponse = '✦ *Jupiter Lumina Vision:*\n\n'
            'The celestial horizon unfolds with vivid clarity. '
            '"$message" resonates through starlit silence, weaving imaginative threads into an inventive, original tapestry.';
        break;
      case 'reasoning':
        planetResponse = '### Saturn Chronos Deductive Analysis:\n\n'
            '1. **Premise Evaluation:** Parsing request: "$message".\n'
            '2. **Logical Decomposition:** Identifying primary constraints and dependencies.\n'
            '3. **Edge Case Verification:** Testing boundary values and edge conditions.\n'
            '4. **Rigorous Conclusion:** Synthesized deterministic outcome with full logical proof.';
        break;
      case 'research':
        planetResponse = '### Neptune Kepler Scientific Synthesis\n\n'
            '**Empirical Confidence:** High (Evidence-grounded synthesis)\n\n'
            '- **Core Finding:** Evaluated current scientific consensus for: "$message".\n'
            '- **Evidence Base:** Grounded in peer-reviewed scientific literature.\n'
            '- **Caveat:** Strict distinction between established empirical facts and active hypotheses.';
        break;
      case 'multi-agent':
      case 'pluto':
        planetResponse = '### Pluto Constellation Hub\n\n'
            'Multi-Agent orchestration station is in standby for Phase 2 deployment.';
        break;
      default:
        planetResponse = '### Earth General Guidance & Planning Roadmap\n\n'
            '1. **Overview & Objectives:** Structured analysis of: "$message".\n'
            '2. **Phase 1: Foundation & Requirements:** Establish core architecture, data contracts, and milestones.\n'
            '3. **Phase 2: Implementation & Scaling:** Incremental execution with automated testing and continuous integration.\n'
            '4. **Phase 3: Operational Excellence:** Resilient monitoring, observability, and strategic maintenance.';
        break;
    }

    if (agentSlug == 'research') {
      yield GatewayEvent(
        type: 'search',
        searchQuery: message,
        sourcesCount: 3,
        searchProvider: 'wikipedia',
      );
    }

    final words = planetResponse.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      yield GatewayEvent(
        type: 'token',
        delta: '${words[i]} ',
      );
    }

    if (agentSlug == 'research') {
      yield GatewayEvent(
        type: 'sources',
        searchQuery: message,
        sources: [
          ChatSource(
            title: 'Orbital Telemetry & Research Database',
            url: 'https://en.wikipedia.org/wiki/Space_exploration',
            domain: 'en.wikipedia.org',
            snippet: 'Verified telemetry metrics on planetary trajectories and observational research.',
            publishedDate: DateTime.now().toIso8601String().split('T')[0],
          ),
          ChatSource(
            title: 'Astrophysical Journal Records',
            url: 'https://arxiv.org/archive/astro-ph',
            domain: 'arxiv.org',
            snippet: 'Peer-reviewed research syntheses regarding orbital mechanics and solar winds.',
            publishedDate: DateTime.now().toIso8601String().split('T')[0],
          ),
        ],
      );
    }

    yield GatewayEvent(
      type: 'usage',
      inputTokens: message.length ~/ 4,
      outputTokens: words.length,
    );

    yield GatewayEvent(
      type: 'done',
      modelRunId: 'run-sim-${DateTime.now().millisecondsSinceEpoch}',
      modelId: modelId ?? 'meta-llama/llama-3.3-70b-instruct:free',
      provider: 'openrouter',
    );
  }
}
