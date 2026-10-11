import 'package:flutter/material.dart';
import '../../../../core/constants/orbit_theme.dart';
import '../../domain/models/planet.dart';

class PlanetSelector extends StatelessWidget {
  final Planet selectedPlanet;
  final ValueChanged<Planet> onPlanetSelected;

  const PlanetSelector({
    super.key,
    required this.selectedPlanet,
    required this.onPlanetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: Planet.allPlanets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final planet = Planet.allPlanets[index];
          final isSelected = planet.slug == selectedPlanet.slug;

          return InkWell(
            onTap: planet.isComingSoon
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(planet.icon, color: planet.primaryColor, size: 16),
                            const SizedBox(width: 8),
                            Text('${planet.planetTitle} constellation is launching in Phase 2!'),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                : () => onPlanetSelected(planet),
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? planet.primaryColor.withAlpha(40)
                    : OrbitTheme.orbitCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? planet.primaryColor
                      : OrbitTheme.orbitCardBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    planet.icon,
                    size: 16,
                    color: planet.isComingSoon
                        ? OrbitTheme.starlightDark
                        : (isSelected ? planet.primaryColor : OrbitTheme.starlightMuted),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    planet.name,
                    style: TextStyle(
                      color: planet.isComingSoon
                          ? OrbitTheme.starlightDark
                          : (isSelected ? OrbitTheme.starWhite : OrbitTheme.starlightMuted),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  if (planet.isComingSoon) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: OrbitTheme.multiAgentPlasma.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(
                          color: OrbitTheme.multiAgentPlasma,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
