import 'package:flutter/material.dart';
import '../../domain/models/planet.dart';
import 'universe_3d_stub.dart'
    if (dart.library.html) 'universe_3d_web.dart' as impl;

Widget getUniverse3dView({
  required void Function(Planet planet) onPlanetSelected,
  required String quality,
}) {
  return impl.buildUniverse3dView(
    onPlanetSelected: onPlanetSelected,
    quality: quality,
  );
}
