import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/orbit_theme.dart';
import '../domain/models/planet.dart';
import 'chat_notifier.dart';
import 'widgets/cosmic_scaffold.dart';
import 'widgets/quota_badge.dart';
import 'widgets/universe_3d_bridge.dart';

class UniverseScreen extends ConsumerStatefulWidget {
  const UniverseScreen({super.key});

  @override
  ConsumerState<UniverseScreen> createState() => _UniverseScreenState();
}

class _UniverseScreenState extends ConsumerState<UniverseScreen> {
  // Quality: 'high', 'low', 'off' (default to 'low' on mobile web or slow devices)
  String _quality = 'high';
  Planet _focusedPlanet = Planet.allPlanets.first;

  @override
  void initState() {
    super.initState();
    // Default to 'low' on mobile web to conserve GPU
    if (kIsWeb) {
      _quality = 'high';
    } else {
      _quality = 'off';
    }
  }

  void _onPlanetSelected(Planet planet) {
    setState(() {
      _focusedPlanet = planet;
    });

    if (planet.isComingSoon) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${planet.name} orbit is arriving in upcoming constellations.'),
          backgroundColor: OrbitTheme.saturnGold,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Switch planet in Riverpod and open chat
    ref.read(chatNotifierProvider.notifier).switchPlanet(planet);
    context.push('/chat');
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final activePlanet = chatState.selectedPlanet;

    return CosmicScaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const Icon(Icons.blur_on, color: OrbitTheme.earthCyan, size: 24),
            const SizedBox(width: 8),
            const Text(
              'ORBITAL UNIVERSE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          _buildQualitySwitcher(),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: QuotaBadge(
              remaining: chatState.remainingQuota,
              onTap: () => context.push('/observatory'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 3D Scene or 2D Fallback Map
          Positioned.fill(
            child: _quality == 'off' || !kIsWeb
                ? _build2dSolarSystem(activePlanet)
                : getUniverse3dView(
                    onPlanetSelected: _onPlanetSelected,
                    quality: _quality,
                  ),
          ),

          // Bottom Planet Details Overlay Panel
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildPlanetPanel(_focusedPlanet),
          ),

          // Top Quick-Nav to Chat
          Positioned(
            top: 16,
            left: 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: OrbitTheme.cosmicSurface.withAlpha(220),
                foregroundColor: OrbitTheme.starWhite,
                side: const BorderSide(color: OrbitTheme.orbitCardBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 16, color: OrbitTheme.earthCyan),
              label: const Text('Open 2D Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              onPressed: () => context.go('/chat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: OrbitTheme.orbitCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrbitTheme.orbitCardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qualityButton('High', 'high'),
          _qualityButton('Low', 'low'),
          _qualityButton('2D', 'off'),
        ],
      ),
    );
  }

  Widget _qualityButton(String label, String value) {
    final isSelected = _quality == value;
    return InkWell(
      onTap: () => setState(() => _quality = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? OrbitTheme.earthCyan.withAlpha(50) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? OrbitTheme.earthCyan : OrbitTheme.starlightDark,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanetPanel(Planet planet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrbitTheme.cosmicSurface.withAlpha(235),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: planet.primaryColor.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(150),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: planet.gradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: planet.primaryColor.withAlpha(100),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(planet.icon, color: OrbitTheme.voidBlack, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      planet.name.toUpperCase(),
                      style: const TextStyle(
                        color: OrbitTheme.starWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: planet.primaryColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        planet.modelLabel,
                        style: TextStyle(
                          color: planet.primaryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  planet.description,
                  style: const TextStyle(
                    color: OrbitTheme.starlightMuted,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: planet.primaryColor,
              foregroundColor: OrbitTheme.voidBlack,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _onPlanetSelected(planet),
            child: Text(
              planet.isComingSoon ? 'LOCKED' : 'TRANSMIT',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build2dSolarSystem(Planet activePlanet) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wb_sunny, color: OrbitTheme.saturnGold, size: 48),
            const SizedBox(height: 6),
            const Text(
              'SOLAR CONSTELLATION',
              style: TextStyle(
                color: OrbitTheme.saturnGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                for (final planet in Planet.allPlanets)
                  _build2dPlanetCard(planet),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _build2dPlanetCard(Planet planet) {
    final isSelected = planet.slug == _focusedPlanet.slug;
    return InkWell(
      onTap: () => setState(() => _focusedPlanet = planet),
      onDoubleTap: () => _onPlanetSelected(planet),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? planet.primaryColor.withAlpha(30)
              : OrbitTheme.orbitCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? planet.primaryColor
                : OrbitTheme.orbitCardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: planet.gradient),
                shape: BoxShape.circle,
              ),
              child: Icon(planet.icon, color: OrbitTheme.voidBlack, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              planet.name,
              style: const TextStyle(
                color: OrbitTheme.starWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              planet.modelLabel,
              style: TextStyle(
                color: planet.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
