import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_orbit/main.dart';
import 'package:ai_orbit/features/chat/domain/models/planet.dart';
import 'package:ai_orbit/features/chat/domain/models/ai_model.dart';
import 'package:ai_orbit/features/chat/data/ai_gateway_data_source.dart';

void main() {
  testWidgets('AI Orbit app launches with Riverpod and GoRouter smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AiOrbitApp(),
      ),
    );
    await tester.pump();

    // Verify planet selector shows Earth
    expect(find.text('EARTH'), findsOneWidget);
  });

  test('Planet personas configuration test', () {
    expect(Planet.allPlanets.length, equals(6));

    final earth = Planet.bySlug('general');
    expect(earth.name, equals('Earth'));
    expect(earth.isComingSoon, isFalse);

    final coding = Planet.bySlug('coding');
    expect(coding.name, equals('Mars'));
    expect(coding.defaultTemperature, equals(0.2));

    final pluto = Planet.bySlug('multi-agent');
    expect(pluto.isComingSoon, isTrue);
  });

  test('Gateway SSE event parsing test', () {
    final tokenEvent = GatewayEvent.fromSSE('token', '{"delta": "Orbital greetings"}');
    expect(tokenEvent.type, equals('token'));
    expect(tokenEvent.delta, equals('Orbital greetings'));

    final fallbackEvent = GatewayEvent.fromSSE(
      'fallback',
      '{"fallback_from": "llama-3.3-70b", "fallback_to": "mistral-large"}',
    );
    expect(fallbackEvent.type, equals('fallback'));
    expect(fallbackEvent.fallbackFrom, equals('llama-3.3-70b'));
    expect(fallbackEvent.fallbackTo, equals('mistral-large'));

    final errorEvent = GatewayEvent.fromSSE(
      'error',
      '{"error_code": "rate_limited", "message": "Too many requests", "retryable": true}',
    );
    expect(errorEvent.type, equals('error'));
    expect(errorEvent.errorCode, equals('rate_limited'));
    expect(errorEvent.retryable, isTrue);
  });

  test('Default AI models priority and provider test', () {
    final models = AiModel.defaultModels();
    expect(models.length, equals(3));
    expect(models[0].provider, equals('groq'));
    expect(models[0].priority, equals(1));
    expect(models[1].provider, equals('openrouter'));
    expect(models[1].priority, equals(2));
  });
}
