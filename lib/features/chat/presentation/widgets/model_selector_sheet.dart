import 'package:flutter/material.dart';
import '../../../../core/constants/orbit_theme.dart';
import '../../domain/models/ai_model.dart';

class ModelSelectorSheet extends StatelessWidget {
  final List<AiModel> models;
  final String? selectedModelId;
  final ValueChanged<AiModel> onModelSelected;

  const ModelSelectorSheet({
    super.key,
    required this.models,
    required this.selectedModelId,
    required this.onModelSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<AiModel> models,
    required String? selectedModelId,
    required ValueChanged<AiModel> onModelSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: OrbitTheme.deepSpace,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ModelSelectorSheet(
        models: models,
        selectedModelId: selectedModelId,
        onModelSelected: onModelSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OrbitTheme.starlightDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.tune, color: OrbitTheme.earthCyan, size: 20),
                SizedBox(width: 8),
                Text(
                  'Select Orbital Model',
                  style: TextStyle(
                    color: OrbitTheme.starWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'If the selected model experiences latency or rate limits, the gateway automatically cascades to fallback priority.',
              style: TextStyle(
                color: OrbitTheme.starlightMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: models.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final model = models[index];
                  final isSelected = model.id == selectedModelId ||
                      (selectedModelId == null && index == 0);

                  return InkWell(
                    onTap: () {
                      onModelSelected(model);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? OrbitTheme.earthCyan.withAlpha(25)
                            : OrbitTheme.orbitCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? OrbitTheme.earthCyan
                              : OrbitTheme.orbitCardBorder,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? OrbitTheme.earthCyan
                                  : OrbitTheme.cosmicSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '#${model.priority}',
                                style: TextStyle(
                                  color: isSelected
                                      ? OrbitTheme.voidBlack
                                      : OrbitTheme.starWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.displayName,
                                  style: const TextStyle(
                                    color: OrbitTheme.starWhite,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Provider: ${model.provider.toUpperCase()} • Context: ${(model.contextWindow / 1000).toStringAsFixed(0)}k',
                                  style: const TextStyle(
                                    color: OrbitTheme.starlightMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: OrbitTheme.earthCyan, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
