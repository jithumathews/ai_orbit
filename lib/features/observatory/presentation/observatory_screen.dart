import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/orbit_theme.dart';
import '../../chat/domain/models/ai_model.dart';
import '../../chat/presentation/widgets/cosmic_scaffold.dart';
import '../domain/models/observatory_telemetry.dart';
import 'observatory_notifier.dart';

class ObservatoryScreen extends ConsumerWidget {
  const ObservatoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryAsync = ref.watch(observatoryNotifierProvider);

    return CosmicScaffold(
      appBar: AppBar(
        title: const Text('OBSERVATORY TELEMETRY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: OrbitTheme.earthCyan),
            onPressed: () => ref.read(observatoryNotifierProvider.notifier).refresh(),
            tooltip: 'Refresh Telemetry',
          ),
        ],
      ),
      body: telemetryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: OrbitTheme.earthCyan),
        ),
        error: (err, _) => Center(
          child: Text('Telemetry error: $err', style: const TextStyle(color: OrbitTheme.marsCrimson)),
        ),
        data: (telemetry) => RefreshIndicator(
          onRefresh: () => ref.read(observatoryNotifierProvider.notifier).refresh(),
          color: OrbitTheme.earthCyan,
          backgroundColor: OrbitTheme.orbitCard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildQuotaCard(telemetry.quota),
              const SizedBox(height: 20),
              const Text(
                'CONSTELLATION MODEL HEALTH (DAY 6 TRACKING)',
                style: TextStyle(
                  color: OrbitTheme.starlightDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              ...telemetry.models.map((model) => _buildModelHealthCard(model)),
              const SizedBox(height: 20),
              _buildArchitectureCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaCard(UserQuota quota) {
    final double percent = (quota.dailyCount / quota.dailyLimit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OrbitTheme.orbitCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrbitTheme.orbitCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Orbital Transmission Quota (Atomic RPC)',
                style: TextStyle(
                  color: OrbitTheme.starWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.bolt, color: OrbitTheme.earthCyan, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: OrbitTheme.voidBlack,
            valueColor: AlwaysStoppedAnimation<Color>(
              percent > 0.8 ? OrbitTheme.marsCrimson : OrbitTheme.earthCyan,
            ),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: ${quota.dailyCount} / ${quota.dailyLimit} requests',
                style: const TextStyle(color: OrbitTheme.starlightMuted, fontSize: 13),
              ),
              Text(
                'Remaining: ${quota.remaining}',
                style: const TextStyle(
                  color: OrbitTheme.starWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tokens Streamed: ${quota.tokenCount} • Reset: 00:00 UTC',
            style: const TextStyle(color: OrbitTheme.starlightDark, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildModelHealthCard(AiModel model) {
    Color statusColor = OrbitTheme.neptuneEmerald;
    String statusLabel = 'ACTIVE';

    if (model.status == 'cooldown') {
      statusColor = OrbitTheme.marsCrimson;
      statusLabel = 'COOLDOWN';
    } else if (model.status == 'degraded') {
      statusColor = OrbitTheme.saturnGold;
      statusLabel = 'DEGRADED';
    } else if (!model.enabled) {
      statusColor = OrbitTheme.starlightDark;
      statusLabel = 'OFFLINE';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrbitTheme.orbitCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OrbitTheme.orbitCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: OrbitTheme.cosmicSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'P${model.priority}',
                      style: const TextStyle(
                        color: OrbitTheme.earthCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    model.displayName,
                    style: const TextStyle(
                      color: OrbitTheme.starWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _metricChip('Provider', model.provider.toUpperCase()),
              const SizedBox(width: 8),
              _metricChip('Context', '${(model.contextWindow / 1000).toStringAsFixed(0)}k tokens'),
              const SizedBox(width: 8),
              _metricChip('RPM Cap', '${model.rpmLimit} rpm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: OrbitTheme.voidBlack,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: OrbitTheme.starlightMuted, fontSize: 11),
      ),
    );
  }

  Widget _buildArchitectureCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrbitTheme.cosmicSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OrbitTheme.orbitCardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: OrbitTheme.earthCyan, size: 16),
              SizedBox(width: 6),
              Text(
                'Gateway Security Protocol',
                style: TextStyle(
                  color: OrbitTheme.starWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            '• Riverpod State Management + Clean Architecture\n'
            '• Zero client secrets: all AI routed via Supabase Edge Function\n'
            '• Atomic PostgreSQL row-lock quota check\n'
            '• Auto-fallback cascade on rate limit / upstream errors',
            style: TextStyle(color: OrbitTheme.starlightMuted, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}
