import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/planet.dart';

final planetNotifierProvider = NotifierProvider<PlanetNotifier, Planet>(() {
  return PlanetNotifier();
});

class PlanetNotifier extends Notifier<Planet> {
  @override
  Planet build() {
    return Planet.allPlanets.first; // Earth (General)
  }

  void selectPlanet(Planet planet) {
    state = planet;
  }
}
