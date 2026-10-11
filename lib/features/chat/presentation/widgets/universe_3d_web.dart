// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import '../../domain/models/planet.dart';

Widget buildUniverse3dView({
  required void Function(Planet planet) onPlanetSelected,
  required String quality,
}) {
  return Universe3dWebWidget(
    onPlanetSelected: onPlanetSelected,
    quality: quality,
  );
}

class Universe3dWebWidget extends StatefulWidget {
  final void Function(Planet planet) onPlanetSelected;
  final String quality;

  const Universe3dWebWidget({
    super.key,
    required this.onPlanetSelected,
    required this.quality,
  });

  @override
  State<Universe3dWebWidget> createState() => _Universe3dWebWidgetState();
}

class _Universe3dWebWidgetState extends State<Universe3dWebWidget> {
  static bool _registered = false;
  static const String viewType = 'universe-3d-iframe';
  static html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    if (!_registered) {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'universe.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#050811';
        _iframe = iframe;
        return iframe;
      });
      _registered = true;
    }

    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['type'] == 'orbit:planet_selected') {
        final slug = data['slug'] as String?;
        if (slug != null) {
          widget.onPlanetSelected(Planet.bySlug(slug));
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant Universe3dWebWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quality != widget.quality && _iframe != null) {
      _iframe?.contentWindow?.postMessage({
        'type': 'orbit:set_quality',
        'quality': widget.quality,
      }, '*');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: viewType);
  }
}
