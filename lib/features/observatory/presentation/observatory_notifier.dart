import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/observatory_repository.dart';
import '../domain/models/observatory_telemetry.dart';

final observatoryNotifierProvider =
    AsyncNotifierProvider<ObservatoryNotifier, ObservatoryTelemetry>(() {
  return ObservatoryNotifier();
});

class ObservatoryNotifier extends AsyncNotifier<ObservatoryTelemetry> {
  @override
  FutureOr<ObservatoryTelemetry> build() async {
    final repo = ref.watch(observatoryRepositoryProvider);
    return repo.getTelemetry();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(observatoryRepositoryProvider);
      return repo.getTelemetry();
    });
  }
}
