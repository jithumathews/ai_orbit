import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_orbit/core/config/model_routing_config.dart';
import 'package:ai_orbit/features/auth/presentation/auth_notifier.dart';
import 'package:ai_orbit/features/chat/domain/models/planet.dart';
import 'package:ai_orbit/features/chat/presentation/planet_notifier.dart';
import 'package:ai_orbit/features/chat/presentation/chat_notifier.dart';
import 'package:ai_orbit/features/chat/presentation/chat_state.dart';

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
    expect(container.read(planetNotifierProvider).specialty, equals('coding and debugging'));
    expect(container.read(planetNotifierProvider).modelLabel, equals('Qwen 2.5 Coder'));
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

  test('PromptAnalyzer and ModelRouter classify queries and select optimal OpenRouter free models', () {
    // 1. Coding query on Mars
    final codeResult = ModelRouter.route(
      planetSlug: 'coding',
      prompt: 'Write a thread-safe LRU cache in Dart with unit tests',
    );
    expect(codeResult.analysis.type, equals(PromptType.code));
    expect(codeResult.chosenModel.id, equals('qwen/qwen-2.5-coder-32b-instruct:free'));
    expect(codeResult.chosenModel.shortLabel, equals('Qwen 2.5 Coder'));

    // 2. Creative query on Jupiter
    final creativeResult = ModelRouter.route(
      planetSlug: 'creative',
      prompt: 'Write a sci-fi prologue about a dying star and orbital explorers',
    );
    expect(codeResult.analysis.type, equals(PromptType.code));
    expect(creativeResult.chosenModel.id, equals('mistralai/mistral-small-24b-instruct-2501:free'));
    expect(creativeResult.chosenModel.shortLabel, equals('Mistral 24B'));

    // 3. Deep reasoning query on Saturn
    final reasoningResult = ModelRouter.route(
      planetSlug: 'reasoning',
      prompt: 'Analyze step by step the logical edge cases in Byzantine fault tolerance',
    );
    expect(reasoningResult.analysis.type, equals(PromptType.reasoning));
    expect(reasoningResult.chosenModel.id, equals('deepseek/deepseek-r1:free'));
    expect(reasoningResult.chosenModel.shortLabel, equals('DeepSeek R1'));

    // 4. Strategic architecture roadmap on Earth
    final roadmapResult = ModelRouter.route(
      planetSlug: 'general',
      prompt: 'Create a step-by-step roadmap for scalable software architecture',
    );
    expect(roadmapResult.chosenModel.id, equals('meta-llama/llama-3.3-70b-instruct:free'));
    expect(roadmapResult.chosenModel.shortLabel, equals('Llama 3.3 70B'));

    // 5. Research and science query on Neptune
    final researchResult = ModelRouter.route(
      planetSlug: 'research',
      prompt: 'Explain CRISPR Cas9 mechanisms and peer-reviewed scientific findings',
    );
    expect(researchResult.analysis.type, equals(PromptType.research));
    expect(researchResult.chosenModel.id, equals('meta-llama/llama-3.3-70b-instruct:free'));
  });

  test('ChatNotifier maintains separate conversation history per planet and supports clear history', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final chatNotifier = container.read(chatNotifierProvider.notifier);
    await chatNotifier.bootstrap();

    // 1. Send message on Earth (general)
    expect(container.read(chatNotifierProvider).selectedPlanet.slug, equals('general'));
    await chatNotifier.sendMessage('Create a step-by-step roadmap for scalable software architecture');
    await Future.delayed(const Duration(milliseconds: 700));

    var earthState = container.read(chatNotifierProvider);
    expect(earthState.messages.length, greaterThanOrEqualTo(2));
    expect(getCurrentModelLabel(earthState), equals('Llama 3.3 70B'));
    final earthMsgCount = earthState.messages.length;

    // 2. Switch to Mars (coding)
    final mars = Planet.bySlug('coding');
    await chatNotifier.switchPlanet(mars);

    var marsState = container.read(chatNotifierProvider);
    expect(marsState.selectedPlanet.slug, equals('coding'));
    // History is separate: Mars history starts empty
    expect(marsState.messages.isEmpty, isTrue);

    // Send coding message on Mars
    await chatNotifier.sendMessage('Debug async stream subscription memory leak in Dart');
    await Future.delayed(const Duration(milliseconds: 700));
    marsState = container.read(chatNotifierProvider);
    expect(marsState.messages.length, greaterThanOrEqualTo(2));
    expect(getCurrentModelLabel(marsState), equals('Qwen 2.5 Coder'));

    // 3. Switch back to Earth: Earth history is preserved separately
    final earth = Planet.bySlug('general');
    await chatNotifier.switchPlanet(earth);
    earthState = container.read(chatNotifierProvider);
    expect(earthState.messages.length, equals(earthMsgCount));

    // 4. Test clear-history for active planet
    await chatNotifier.clearActivePlanetHistory();
    earthState = container.read(chatNotifierProvider);
    expect(earthState.messages.isEmpty, isTrue);

    // Verify Mars history was not deleted when Earth was cleared
    await chatNotifier.switchPlanet(mars);
    marsState = container.read(chatNotifierProvider);
    expect(marsState.messages.isNotEmpty, isTrue);
  });
}
