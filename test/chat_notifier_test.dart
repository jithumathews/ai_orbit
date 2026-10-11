import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_orbit/features/auth/presentation/auth_notifier.dart';
import 'package:ai_orbit/features/chat/domain/models/planet.dart';
import 'package:ai_orbit/features/chat/presentation/planet_notifier.dart';
import 'package:ai_orbit/features/chat/presentation/chat_notifier.dart';

void main() {
  test('PlanetNotifier changes active planet correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial planet is Earth (General)
    expect(container.read(planetNotifierProvider).slug, equals('general'));

    // Switch to Mars (Coding)
    final mars = Planet.bySlug('coding');
    container.read(planetNotifierProvider.notifier).selectPlanet(mars);

    expect(container.read(planetNotifierProvider).slug, equals('coding'));
    expect(container.read(planetNotifierProvider).defaultTemperature, equals(0.2));
  });

  test('AuthNotifier handles demo login and signout', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final authNotifier = container.read(authNotifierProvider.notifier);

    // Enter demo pass
    authNotifier.enterDemoPass();
    final authState = container.read(authNotifierProvider);

    expect(authState.isAuthenticated, isTrue);
    expect(authState.isMockMode, isTrue);
    expect(authState.email, equals('demo@ai-orbit.space'));

    // Sign out
    await authNotifier.signOut();
    final signedOutState = container.read(authNotifierProvider);

    expect(signedOutState.isAuthenticated, isFalse);
  });

  test('ChatNotifier bootstrap and message streaming lifecycle', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final chatNotifier = container.read(chatNotifierProvider.notifier);

    // Bootstrap chat state
    await chatNotifier.bootstrap();
    var state = container.read(chatNotifierProvider);

    expect(state.selectedPlanet.slug, equals('general'));
    expect(state.activeConversation, isNotNull);
    expect(state.remainingQuota, equals(50));

    // Send message (runs high-fidelity simulation in mock mode)
    await chatNotifier.sendMessage('Test orbital prompt');
    state = container.read(chatNotifierProvider);

    // Should have user message and assistant message
    expect(state.messages.length, greaterThanOrEqualTo(2));
    expect(state.messages.first.role, equals('user'));
    expect(state.messages.first.content, equals('Test orbital prompt'));
    expect(state.messages.last.role, equals('assistant'));
  });
}
