import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';
import '../domain/models/ai_model.dart';

final modelsNotifierProvider = AsyncNotifierProvider<ModelsNotifier, List<AiModel>>(() {
  return ModelsNotifier();
});

class ModelsNotifier extends AsyncNotifier<List<AiModel>> {
  @override
  FutureOr<List<AiModel>> build() async {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.getEnabledModels();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(chatRepositoryProvider);
      return repo.getEnabledModels();
    });
  }
}
