import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/orbit_theme.dart';

part 'planet.freezed.dart';

@freezed
class Planet with _$Planet {
  const Planet._();

  const factory Planet({
    required String slug,
    required String name,
    required String planetTitle,
    required String description,
    required IconData icon,
    required Color primaryColor,
    required List<Color> gradient,
    @Default(false) bool isComingSoon,
    @Default(0.7) double defaultTemperature,
  }) = _Planet;

  static const List<Planet> allPlanets = [
    Planet(
      slug: 'general',
      name: 'Earth',
      planetTitle: 'General Orbit',
      description: 'Friendly, concise, everyday cosmic assistance.',
      icon: Icons.public,
      primaryColor: OrbitTheme.earthCyan,
      gradient: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      defaultTemperature: 0.7,
    ),
    Planet(
      slug: 'coding',
      name: 'Mars',
      planetTitle: 'Cybertron Engineer',
      description: 'Precise code, architectures, and architectural trade-offs.',
      icon: Icons.code,
      primaryColor: OrbitTheme.marsCrimson,
      gradient: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      defaultTemperature: 0.2,
    ),
    Planet(
      slug: 'creative',
      name: 'Jupiter',
      planetTitle: 'Lumina Creative',
      description: 'Imaginative storytelling, metaphors, and cosmic copy.',
      icon: Icons.auto_awesome,
      primaryColor: OrbitTheme.jupiterViolet,
      gradient: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      defaultTemperature: 0.9,
    ),
    Planet(
      slug: 'reasoning',
      name: 'Saturn',
      planetTitle: 'Chronos Deep Reasoner',
      description: 'Step-by-step logic, edge case analysis, and deduction.',
      icon: Icons.psychology,
      primaryColor: OrbitTheme.saturnGold,
      gradient: [Color(0xFFF7971E), Color(0xFFFFD200)],
      defaultTemperature: 0.1,
    ),
    Planet(
      slug: 'research',
      name: 'Neptune',
      planetTitle: 'Kepler Research',
      description: 'Objective synthesis, uncertainty acknowledgment, zero hallucinations.',
      icon: Icons.biotech,
      primaryColor: OrbitTheme.neptuneEmerald,
      gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
      defaultTemperature: 0.3,
    ),
    Planet(
      slug: 'multi-agent',
      name: 'Pluto',
      planetTitle: 'Multi-Agent Orbit',
      description: 'Autonomous multi-agent constellation missions.',
      icon: Icons.hub,
      primaryColor: OrbitTheme.multiAgentPlasma,
      gradient: [Color(0xFFFF4081), Color(0xFF7C4DFF)],
      isComingSoon: true,
      defaultTemperature: 0.5,
    ),
  ];

  static Planet bySlug(String slug) {
    return allPlanets.firstWhere(
      (p) => p.slug == slug,
      orElse: () => allPlanets.first,
    );
  }

  /// Short model name shown in AppBar badge (read-only, no dropdown)
  String get modelLabel {
    switch (slug) {
      case 'general':
        return 'OpenRouter Free';
      case 'coding':
        return 'Cohere Code';
      case 'creative':
        return 'OpenRouter Free';
      case 'reasoning':
        return 'OpenRouter Free';
      case 'research':
        return 'OpenRouter Free';
      default:
        return 'AI Model';
    }
  }
}
