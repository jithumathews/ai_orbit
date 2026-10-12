// AI Orbit — Model Routing & Prompt Analysis Configuration
// Provides centralized rules for classifying user prompts, selecting optimal OpenRouter free models,
// and establishing fallback priority chains per planet persona.

enum PromptType {
  taskCommand,
  code,
  creative,
  reasoning,
  research,
  simpleChat,
}

enum ComplexityLevel {
  simple,
  complex,
}

class PromptAnalysis {
  final PromptType type;
  final ComplexityLevel complexity;
  final String rationale;

  const PromptAnalysis({
    required this.type,
    required this.complexity,
    required this.rationale,
  });

  @override
  String toString() => 'PromptAnalysis(type: $type, complexity: $complexity, rationale: "$rationale")';
}

class OpenRouterFreeModel {
  final String id;
  final String displayName;
  final String shortLabel;
  final List<String> capabilities;
  final int contextWindow;
  final int priority;

  const OpenRouterFreeModel({
    required this.id,
    required this.displayName,
    required this.shortLabel,
    required this.capabilities,
    required this.contextWindow,
    required this.priority,
  });
}

class ModelRoutingResult {
  final OpenRouterFreeModel chosenModel;
  final List<OpenRouterFreeModel> fallbackQueue;
  final PromptAnalysis analysis;

  const ModelRoutingResult({
    required this.chosenModel,
    required this.fallbackQueue,
    required this.analysis,
  });
}

class ModelRoutingConfig {
  // Registry of verified OpenRouter Free models
  static const OpenRouterFreeModel llama33_70b = OpenRouterFreeModel(
    id: 'meta-llama/llama-3.3-70b-instruct:free',
    displayName: 'Meta Llama 3.3 70B Free',
    shortLabel: 'Llama 3.3 70B',
    capabilities: ['chat', 'planning', 'roadmaps', 'reasoning'],
    contextWindow: 131072,
    priority: 1,
  );

  static const OpenRouterFreeModel qwenCoder32b = OpenRouterFreeModel(
    id: 'qwen/qwen-2.5-coder-32b-instruct:free',
    displayName: 'Qwen 2.5 Coder 32B Free',
    shortLabel: 'Qwen 2.5 Coder',
    capabilities: ['code', 'debugging', 'architecture'],
    contextWindow: 131072,
    priority: 2,
  );

  static const OpenRouterFreeModel deepseekR1 = OpenRouterFreeModel(
    id: 'deepseek/deepseek-r1:free',
    displayName: 'DeepSeek R1 Free',
    shortLabel: 'DeepSeek R1',
    capabilities: ['reasoning', 'logic', 'math', 'analysis'],
    contextWindow: 131072,
    priority: 3,
  );

  static const OpenRouterFreeModel mistralSmall24b = OpenRouterFreeModel(
    id: 'mistralai/mistral-small-24b-instruct-2501:free',
    displayName: 'Mistral Small 24B Free',
    shortLabel: 'Mistral 24B',
    capabilities: ['creative', 'writing', 'ideation'],
    contextWindow: 131072,
    priority: 4,
  );

  static const OpenRouterFreeModel geminiFlash = OpenRouterFreeModel(
    id: 'google/gemini-2.0-flash-exp:free',
    displayName: 'Google Gemini 2.0 Flash Free',
    shortLabel: 'Gemini 2.0 Flash',
    capabilities: ['research', 'science', 'explanations', 'fast'],
    contextWindow: 131072,
    priority: 5,
  );

  static const OpenRouterFreeModel llama31_8b = OpenRouterFreeModel(
    id: 'meta-llama/llama-3.1-8b-instruct:free',
    displayName: 'Meta Llama 3.1 8B Free',
    shortLabel: 'Llama 3.1 8B',
    capabilities: ['chat', 'simpleChat', 'fast'],
    contextWindow: 131072,
    priority: 6,
  );

  static const OpenRouterFreeModel openrouterAuto = OpenRouterFreeModel(
    id: 'openrouter/free',
    displayName: 'OpenRouter Auto Free',
    shortLabel: 'OpenRouter Auto',
    capabilities: ['chat', 'fallback'],
    contextWindow: 131072,
    priority: 7,
  );

  static const List<OpenRouterFreeModel> allModels = [
    llama33_70b,
    qwenCoder32b,
    deepseekR1,
    mistralSmall24b,
    geminiFlash,
    llama31_8b,
    openrouterAuto,
  ];

  static OpenRouterFreeModel getModelById(String modelId) {
    return allModels.firstWhere(
      (m) => m.id == modelId,
      orElse: () => openrouterAuto,
    );
  }

  // Preferred model for each planet
  static const Map<String, String> planetPreferredModelId = {
    'general': 'meta-llama/llama-3.3-70b-instruct:free', // Earth: General & roadmaps
    'coding': 'qwen/qwen-2.5-coder-32b-instruct:free',    // Mars: Coding & debugging
    'creative': 'mistralai/mistral-small-24b-instruct-2501:free', // Jupiter: Creative writing
    'reasoning': 'deepseek/deepseek-r1:free',             // Saturn: Deep reasoning
    'research': 'meta-llama/llama-3.3-70b-instruct:free', // Neptune: Research & science
    'multi-agent': 'openrouter/free',                    // Pluto: Multi-agent
    'pluto': 'openrouter/free',
  };

  // Allowed models per planet (order determines default routing preference)
  static const Map<String, List<String>> planetAllowedModelIds = {
    'general': [
      'meta-llama/llama-3.3-70b-instruct:free',
      'deepseek/deepseek-r1:free',
      'mistralai/mistral-small-24b-instruct-2501:free',
      'openrouter/free',
    ],
    'coding': [
      'qwen/qwen-2.5-coder-32b-instruct:free',
      'deepseek/deepseek-r1:free',
      'meta-llama/llama-3.3-70b-instruct:free',
      'openrouter/free',
    ],
    'creative': [
      'mistralai/mistral-small-24b-instruct-2501:free',
      'meta-llama/llama-3.3-70b-instruct:free',
      'google/gemini-2.0-flash-exp:free',
      'openrouter/free',
    ],
    'reasoning': [
      'deepseek/deepseek-r1:free',
      'meta-llama/llama-3.3-70b-instruct:free',
      'mistralai/mistral-small-24b-instruct-2501:free',
      'openrouter/free',
    ],
    'research': [
      'meta-llama/llama-3.3-70b-instruct:free',
      'google/gemini-2.0-flash-exp:free',
      'deepseek/deepseek-r1:free',
      'openrouter/free',
    ],
    'multi-agent': [
      'openrouter/free',
    ],
    'pluto': [
      'openrouter/free',
    ],
  };
}

/// Prompt Analyzer: classifies query into prompt type and complexity
class PromptAnalyzer {
  static final RegExp _codePatterns = RegExp(
    r'(\b(code|function|class|method|struct|enum|interface|async|await|return|import|package|def|val|var|const|let|lambda)\b|```|\b(flutter|dart|python|javascript|typescript|c\+\+|java|rust|sql|html|css|json|api|endpoint|git|bash|docker)\b|\b(bug|debug|error|exception|crash|trace|compile|refactor|unit\s*test|algorithm|stacktrace)\b|[\{\}\[\]\<\>\=\;]{3,})',
    caseSensitive: false,
  );

  static final RegExp _creativePatterns = RegExp(
    r'\b(story|poem|poetry|novel|prose|fiction|metaphor|creative|brainstorm|ideat|narrative|dialogue|character|plot|rhyme|haiku|lyric|creative\s*writing|world-building|fantasy|sci-fi|lore)\b',
    caseSensitive: false,
  );

  static final RegExp _reasoningPatterns = RegExp(
    r'\b(reason|logic|why|analyze|deduc|proof|step-by-step|step\s+by\s+step|trade-off|tradeoff|paradox|puzzle|premise|counterargument|implication|evaluate|pros\s*and\s*cons|root\s*cause|compare\s*and\s*contrast|causality)\b',
    caseSensitive: false,
  );

  static final RegExp _researchPatterns = RegExp(
    r'\b(research|science|scientific|experiment|study|paper|academic|evidence|hypothesis|discovery|quantum|physics|biology|chemistry|astronomy|medicine|history|explain\s+how|what\s+is\s+the|origins\s+of|findings|citation)\b',
    caseSensitive: false,
  );

  static final RegExp _planningPatterns = RegExp(
    r'\b(roadmap|plan|milestone|strategy|architecture\s*plan|phases|timeline|step-by-step\s*guide|action\s*plan|framework|implementation\s*steps|blueprint)\b',
    caseSensitive: false,
  );

  static final RegExp _simpleGreetings = RegExp(
    r'^\s*(hello|hi|hey|greetings|good\s*(morning|afternoon|evening)|howdy|sup|yo|thanks|thank\s*you|ok|cool|bye)\b[\s\!\.\?]*$',
    caseSensitive: false,
  );

  static final RegExp _directTaskCommandPatterns = RegExp(
    r'(\b(add\s+(a\s+)?tasks?(\s+to)?|create\s+(a\s+)?tasks?(\s+to)?|new\s+tasks?(\s+to)?|remind\s+me\s+to|todos?:?|to-dos?:?|assign\s+tasks?)\b|^\s*/tasks?\b)',
    caseSensitive: false,
  );

  static final RegExp _actionVerbs = RegExp(
    r'\b(deploy|test|write|fix|update|implement|review|verify|check|create|build|prepare|refactor|design|ship|publish|audit|configure|patch|run|inspect)\b',
    caseSensitive: false,
  );

  static final RegExp _temporalPatterns = RegExp(
    r'\b(today|tomorrow|by\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)|next\s+week|this\s+week|by\s+tonight|asap|urgent|urgently|by\s+end\s+of\s+day|by\s+eod)\b',
    caseSensitive: false,
  );

  static bool isTaskIntent(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    // 1. Direct task command prefix
    if (_directTaskCommandPatterns.hasMatch(trimmed)) {
      return true;
    }

    // 2. Multi-clause imperative sentence with dates (e.g. "Deploy X today, test Y tomorrow, and write Z by Monday")
    final hasTemporal = _temporalPatterns.hasMatch(trimmed);
    if (hasTemporal) {
      final verbMatches = _actionVerbs.allMatches(trimmed);
      if (verbMatches.length >= 2) {
        return true;
      }
      if (verbMatches.isNotEmpty &&
          (trimmed.toLowerCase().contains('assign') ||
           trimmed.toLowerCase().contains('give it to') ||
           trimmed.toLowerCase().contains('urgent') ||
           trimmed.toLowerCase().contains('asap'))) {
        return true;
      }
    }

    return false;
  }

  static PromptAnalysis analyze(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const PromptAnalysis(
        type: PromptType.simpleChat,
        complexity: ComplexityLevel.simple,
        rationale: 'Empty prompt defaulted to simple chat',
      );
    }

    // Phase B: Task intent checked before everything else
    if (isTaskIntent(trimmed)) {
      return const PromptAnalysis(
        type: PromptType.taskCommand,
        complexity: ComplexityLevel.complex,
        rationale: 'Actionable task creation command or multi-action schedule detected',
      );
    }

    // Check simple conversational greetings (strictly short greetings <= 4 words without action verbs)
    final wordList = trimmed.split(RegExp(r'\s+'));
    if (_simpleGreetings.hasMatch(trimmed) && wordList.length <= 4 && !_actionVerbs.hasMatch(trimmed)) {
      return const PromptAnalysis(
        type: PromptType.simpleChat,
        complexity: ComplexityLevel.simple,
        rationale: 'Short conversational greeting or acknowledgment',
      );
    }

    // Detect prompt type by match density
    final isCode = _codePatterns.hasMatch(trimmed);
    final isPlanning = _planningPatterns.hasMatch(trimmed);
    final isReasoning = _reasoningPatterns.hasMatch(trimmed);
    final isResearch = _researchPatterns.hasMatch(trimmed);
    final isCreative = _creativePatterns.hasMatch(trimmed);

    // Complexity evaluation
    final wordCount = trimmed.split(RegExp(r'\s+')).length;
    final hasMultiClauses = trimmed.contains(';') || trimmed.contains('1.') || trimmed.contains('- ') || trimmed.contains('\n');
    final isComplex = wordCount > 40 || hasMultiClauses || trimmed.length > 250;
    final complexity = isComplex ? ComplexityLevel.complex : ComplexityLevel.simple;

    if (isCode) {
      return PromptAnalysis(
        type: PromptType.code,
        complexity: complexity,
        rationale: 'Technical keywords or code syntax detected',
      );
    }

    if (isPlanning) {
      // Planning / roadmaps map to reasoning or general planning
      return PromptAnalysis(
        type: PromptType.reasoning,
        complexity: ComplexityLevel.complex,
        rationale: 'Structured roadmap / planning query detected',
      );
    }

    if (isReasoning) {
      return PromptAnalysis(
        type: PromptType.reasoning,
        complexity: complexity,
        rationale: 'Analytical deduction or comparative logic requested',
      );
    }

    if (isResearch) {
      return PromptAnalysis(
        type: PromptType.research,
        complexity: complexity,
        rationale: 'Scientific explanation or evidence-based inquiry requested',
      );
    }

    if (isCreative) {
      return PromptAnalysis(
        type: PromptType.creative,
        complexity: complexity,
        rationale: 'Imaginative writing, narrative, or creative ideation requested',
      );
    }

    // Default general query
    return PromptAnalysis(
      type: wordCount > 15 ? PromptType.reasoning : PromptType.simpleChat,
      complexity: complexity,
      rationale: 'General multi-sentence query',
    );
  }
}

/// Model Router: Selects the best OpenRouter Free model within active planet's constraints
class ModelRouter {
  static ModelRoutingResult route({
    required String planetSlug,
    required String prompt,
  }) {
    final analysis = PromptAnalyzer.analyze(prompt);
    final allowedIds = ModelRoutingConfig.planetAllowedModelIds[planetSlug] ??
        ModelRoutingConfig.planetAllowedModelIds['general']!;
    final preferredId = ModelRoutingConfig.planetPreferredModelId[planetSlug] ??
        ModelRoutingConfig.llama33_70b.id;

    final preferredModel = ModelRoutingConfig.getModelById(preferredId);
    final allowedModels = allowedIds.map((id) => ModelRoutingConfig.getModelById(id)).toList();

    // Determine target model based on Prompt Type and Planet specialty
    OpenRouterFreeModel chosenModel;

    switch (analysis.type) {
      case PromptType.taskCommand:
        // Use high-capacity planning/reasoning model (Llama 3.3 70B or planet's preferred)
        if (allowedIds.contains(ModelRoutingConfig.llama33_70b.id)) {
          chosenModel = ModelRoutingConfig.llama33_70b;
        } else {
          chosenModel = preferredModel;
        }
        break;

      case PromptType.code:
        // Prefer Qwen Coder if allowed on this planet, otherwise planet's preferred
        if (allowedIds.contains(ModelRoutingConfig.qwenCoder32b.id)) {
          chosenModel = ModelRoutingConfig.qwenCoder32b;
        } else if (allowedIds.contains(ModelRoutingConfig.deepseekR1.id)) {
          chosenModel = ModelRoutingConfig.deepseekR1;
        } else {
          chosenModel = preferredModel;
        }
        break;

      case PromptType.reasoning:
        // Prefer DeepSeek R1 for reasoning, or Llama 3.3 70B for planning/roadmaps
        if (planetSlug == 'general' && allowedIds.contains(ModelRoutingConfig.llama33_70b.id)) {
          chosenModel = ModelRoutingConfig.llama33_70b;
        } else if (allowedIds.contains(ModelRoutingConfig.deepseekR1.id)) {
          chosenModel = ModelRoutingConfig.deepseekR1;
        } else if (allowedIds.contains(ModelRoutingConfig.llama33_70b.id)) {
          chosenModel = ModelRoutingConfig.llama33_70b;
        } else {
          chosenModel = preferredModel;
        }
        break;

      case PromptType.creative:
        // Prefer Mistral Small 24B
        if (allowedIds.contains(ModelRoutingConfig.mistralSmall24b.id)) {
          chosenModel = ModelRoutingConfig.mistralSmall24b;
        } else if (allowedIds.contains(ModelRoutingConfig.llama33_70b.id)) {
          chosenModel = ModelRoutingConfig.llama33_70b;
        } else {
          chosenModel = preferredModel;
        }
        break;

      case PromptType.research:
        // Prefer Gemini Flash or Llama 3.3 70B
        if (planetSlug == 'research' && allowedIds.contains(ModelRoutingConfig.llama33_70b.id)) {
          chosenModel = ModelRoutingConfig.llama33_70b;
        } else if (allowedIds.contains(ModelRoutingConfig.geminiFlash.id)) {
          chosenModel = ModelRoutingConfig.geminiFlash;
        } else if (allowedIds.contains(ModelRoutingConfig.llama33_70b.id)) {
          chosenModel = ModelRoutingConfig.llama33_70b;
        } else {
          chosenModel = preferredModel;
        }
        break;

      case PromptType.simpleChat:
        // Simple chat: if low complexity, can use fast Llama 3.1 8B if allowed, else preferred
        if (analysis.complexity == ComplexityLevel.simple &&
            allowedIds.contains(ModelRoutingConfig.llama31_8b.id)) {
          chosenModel = ModelRoutingConfig.llama31_8b;
        } else {
          chosenModel = preferredModel;
        }
        break;
    }

    // Build fallback queue: [chosenModel, ...other allowed models without duplicates]
    final queue = <OpenRouterFreeModel>[chosenModel];
    for (final model in allowedModels) {
      if (!queue.any((m) => m.id == model.id)) {
        queue.add(model);
      }
    }
    // Ensure planet's preferred model is always in the fallback queue
    if (!queue.any((m) => m.id == preferredModel.id)) {
      queue.add(preferredModel);
    }
    // Ensure openrouterAuto is always the final resilient safeguard
    if (!queue.any((m) => m.id == ModelRoutingConfig.openrouterAuto.id)) {
      queue.add(ModelRoutingConfig.openrouterAuto);
    }

    return ModelRoutingResult(
      chosenModel: chosenModel,
      fallbackQueue: queue,
      analysis: analysis,
    );
  }
}
