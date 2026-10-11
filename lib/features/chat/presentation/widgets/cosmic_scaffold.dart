import 'package:flutter/material.dart';
import '../../../../core/constants/orbit_theme.dart';

class CosmicScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const CosmicScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      backgroundColor: OrbitTheme.voidBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.7, -0.6),
                  radius: 1.2,
                  colors: [
                    Color(0x1A00E5FF),
                    Color(0x0A7C4DFF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.8, 0.7),
                  radius: 1.0,
                  colors: [
                    Color(0x14B388FF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(child: body),
        ],
      ),
    );
  }
}
