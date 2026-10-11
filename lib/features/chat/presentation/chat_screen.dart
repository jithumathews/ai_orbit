import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/orbit_config.dart';
import '../../../../core/constants/orbit_theme.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../domain/models/planet.dart';
import 'chat_notifier.dart';
import 'widgets/cosmic_scaffold.dart';
import 'widgets/message_bubble.dart';
import 'widgets/planet_drawer.dart';
import 'widgets/planet_selector.dart';
import 'widgets/quota_badge.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).bootstrap();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (text.length > OrbitConfig.maxMessageLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message exceeds 4,000 character limit.'),
          backgroundColor: OrbitTheme.marsCrimson,
        ),
      );
      return;
    }

    _inputController.clear();
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }


  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    ref.listen(chatNotifierProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          (previous?.isStreaming == false && next.isStreaming)) {
        _scrollToBottom();
      }
    });

    return CosmicScaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Icon(
              chatState.selectedPlanet.icon,
              color: chatState.selectedPlanet.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              chatState.selectedPlanet.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: OrbitTheme.orbitCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: chatState.selectedPlanet.primaryColor.withAlpha(80)),
              ),
              child: Text(
                chatState.selectedPlanet.modelLabel,
                style: TextStyle(
                  color: chatState.selectedPlanet.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: QuotaBadge(
              remaining: chatState.remainingQuota,
              onTap: () => context.push('/observatory'),
            ),
          ),
        ],
      ),
      drawer: PlanetDrawer(
        conversations: chatState.conversations,
        activeConversationId: chatState.activeConversation?.id,
        userEmail: authState.email,
        isMockMode: authState.isMockMode,
        onSelectConversation: (conv) {
          ref.read(chatNotifierProvider.notifier).selectConversation(conv);
        },
        onNewTransmission: () {
          ref.read(chatNotifierProvider.notifier).startNewConversation();
        },
        onOpenObservatory: () {
          context.push('/observatory');
        },
        onSignOut: () async {
          await ref.read(authNotifierProvider.notifier).signOut();
          if (context.mounted) {
            context.go('/auth');
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: PlanetSelector(
              selectedPlanet: chatState.selectedPlanet,
              onPlanetSelected: (planet) {
                ref.read(chatNotifierProvider.notifier).switchPlanet(planet);
              },
            ),
          ),
          const Divider(color: OrbitTheme.orbitCardBorder, height: 1),

          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState(chatState.selectedPlanet)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatState.messages[index];
                      return MessageBubble(
                        message: msg,
                        currentPlanet: chatState.selectedPlanet,
                        onRetry: msg.isError
                            ? () => ref.read(chatNotifierProvider.notifier).retryLastMessage()
                            : null,
                      );
                    },
                  ),
          ),

          _buildInputBar(chatState),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Planet planet) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: planet.gradient),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: planet.primaryColor.withAlpha(60),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(planet.icon, color: OrbitTheme.voidBlack, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                planet.planetTitle,
                style: const TextStyle(
                  color: OrbitTheme.starWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                planet.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: OrbitTheme.starlightMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _suggestionChip('Summarize orbital telemetry'),
                  _suggestionChip('Analyze system architecture trade-offs'),
                  _suggestionChip('Deduce step-by-step logic'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestionChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(color: OrbitTheme.starlightMuted, fontSize: 11)),
      backgroundColor: OrbitTheme.orbitCard,
      side: const BorderSide(color: OrbitTheme.orbitCardBorder),
      onPressed: () {
        _inputController.text = label;
        _sendMessage();
      },
    );
  }

  Widget _buildInputBar(dynamic chatState) {
    final isStreaming = chatState.isStreaming as bool;
    final planet = chatState.selectedPlanet as Planet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: OrbitTheme.deepSpace,
        border: Border(top: BorderSide(color: OrbitTheme.orbitCardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: OrbitTheme.orbitCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: OrbitTheme.orbitCardBorder),
                ),
                child: TextField(
                  controller: _inputController,
                  maxLines: 5,
                  minLines: 1,
                  style: const TextStyle(color: OrbitTheme.starWhite, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Transmit message across the orbit...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: planet.gradient),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: isStreaming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: OrbitTheme.voidBlack,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: OrbitTheme.voidBlack, size: 20),
                onPressed: isStreaming ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
