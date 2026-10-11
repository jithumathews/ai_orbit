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
      description: 'General assistant and planning/roadmaps.',
      icon: Icons.public,
      primaryColor: OrbitTheme.earthCyan,
      gradient: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      defaultTemperature: 0.7,
    ),
    Planet(
      slug: 'coding',
      name: 'Mars',
      planetTitle: 'Cybertron Engineer',
      description: 'Coding, debugging, and systems architecture.',
      icon: Icons.code,
      primaryColor: OrbitTheme.marsCrimson,
      gradient: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      defaultTemperature: 0.2,
    ),
    Planet(
      slug: 'creative',
      name: 'Jupiter',
      planetTitle: 'Lumina Creative',
      description: 'Creative writing, storytelling, and idea generation.',
      icon: Icons.auto_awesome,
      primaryColor: OrbitTheme.jupiterViolet,
      gradient: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      defaultTemperature: 0.85,
    ),
    Planet(
      slug: 'reasoning',
      name: 'Saturn',
      planetTitle: 'Chronos Deep Reasoner',
      description: 'Deep reasoning, analytical deduction, and complex problem-solving.',
      icon: Icons.psychology,
      primaryColor: OrbitTheme.saturnGold,
      gradient: [Color(0xFFF7971E), Color(0xFFFFD200)],
      defaultTemperature: 0.1,
    ),
    Planet(
      slug: 'research',
      name: 'Neptune',
      planetTitle: 'Kepler Research',
      description: 'Scientific research, evidence synthesis, and explanations.',
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
    if (slug == 'pluto') {
      return allPlanets.firstWhere((p) => p.slug == 'multi-agent');
    }
    return allPlanets.firstWhere(
      (p) => p.slug == slug,
      orElse: () => allPlanets.first,
    );
  }

  /// Specialty description for planet
  String get specialty {
    switch (slug) {
      case 'general':
        return 'general assistant and planning/roadmaps';
      case 'coding':
        return 'coding and debugging';
      case 'creative':
        return 'creative writing and ideas';
      case 'reasoning':
        return 'deep reasoning and analysis';
      case 'research':
        return 'research, science and explanations';
      default:
        return 'autonomous multi-agent constellation';
    }
  }

  /// Preferred OpenRouter free model ID
  String get preferredModelId {
    switch (slug) {
      case 'general':
        return 'meta-llama/llama-3.3-70b-instruct:free';
      case 'coding':
        return 'qwen/qwen-2.5-coder-32b-instruct:free';
      case 'creative':
        return 'mistralai/mistral-small-24b-instruct-2501:free';
      case 'reasoning':
        return 'deepseek/deepseek-r1:free';
      case 'research':
        return 'meta-llama/llama-3.3-70b-instruct:free';
      default:
        return 'openrouter/free';
    }
  }

  /// Model name shown in AppBar badge
  String get modelLabel {
    switch (slug) {
      case 'general':
        return 'Llama 3.3 70B';
      case 'coding':
        return 'Qwen 2.5 Coder';
      case 'creative':
        return 'Mistral 24B';
      case 'reasoning':
        return 'DeepSeek R1';
      case 'research':
        return 'Llama 3.3 70B';
      default:
        return 'OpenRouter Auto';
    }
  }
}
