import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/orbit_config.dart';
import '../../../../core/config/model_routing_config.dart';
import '../../../../core/constants/orbit_theme.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/presentation/task_notifier.dart';
import '../../tasks/presentation/workspace_notifier.dart';
import '../../tasks/presentation/widgets/task_badge.dart';
import '../../tasks/presentation/widgets/task_panel.dart';
import '../../tasks/presentation/widgets/task_suggestions_card.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/planet.dart';
import 'chat_notifier.dart';
import 'chat_state.dart';
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
  List<Map<String, dynamic>>? _extractedDrafts;
  String? _extractedSourceMsgId;
  bool _isExtracting = false;

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

  Future<void> _handleNaturalLanguageQuickAdd(String prompt) async {
    final userMsg = await ref.read(chatNotifierProvider.notifier).addUserMessageOnly(prompt);
    setState(() {
      _isExtracting = true;
      _extractedSourceMsgId = userMsg.id;
    });
    _scrollToBottom();

    final wsState = ref.read(workspaceNotifierProvider);
    try {
      final drafts = await ref.read(taskRepositoryProvider).parseTasksFromText(
        text: prompt,
        workspaceId: wsState.activeWorkspace?.id,
      );
      if (mounted) {
        setState(() {
          _isExtracting = false;
          _extractedDrafts = drafts.isNotEmpty ? drafts : null;
        });
        if (drafts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No actionable tasks found in your transmission. Try rephrasing with specific action items.'),
              backgroundColor: OrbitTheme.starlightDark,
            ),
          );
        } else {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExtracting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to parse task: $e'),
            backgroundColor: OrbitTheme.marsCrimson,
          ),
        );
      }
    }
  }

  Future<void> _extractTasksFromMessage(ChatMessage message) async {
    setState(() => _isExtracting = true);
    final wsState = ref.read(workspaceNotifierProvider);
    try {
      final drafts = await ref.read(taskRepositoryProvider).extractTasksFromMessage(
        messageId: message.id,
        workspaceId: wsState.activeWorkspace?.id,
      );
      if (mounted) {
        setState(() {
          _isExtracting = false;
          _extractedDrafts = drafts.isNotEmpty ? drafts : null;
          _extractedSourceMsgId = message.id;
        });
        if (drafts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No action items found in this transmission.'),
              backgroundColor: OrbitTheme.starlightDark,
            ),
          );
        } else {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExtracting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to extract tasks: $e'),
            backgroundColor: OrbitTheme.marsCrimson,
          ),
        );
      }
    }
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

    // Phase B: Intercept task intent BEFORE sending to chat or web search
    if (PromptAnalyzer.isTaskIntent(text)) {
      _handleNaturalLanguageQuickAdd(text);
      return;
    }

    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }


  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final taskState = ref.watch(taskNotifierProvider);

    ref.listen(chatNotifierProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          (previous?.isStreaming == false && next.isStreaming)) {
        _scrollToBottom();
      }
    });

    ref.listen<String>(chatDraftInputProvider, (previous, next) {
      if (next.isNotEmpty) {
        _inputController.text = next;
        ref.read(chatDraftInputProvider.notifier).state = '';
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
                getCurrentModelLabel(chatState),
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
          IconButton(
            tooltip: 'Clear ${chatState.selectedPlanet.name} History',
            icon: const Icon(Icons.delete_sweep_outlined, color: OrbitTheme.starlightMuted, size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: OrbitTheme.deepSpace,
                  title: Text(
                    'Clear ${chatState.selectedPlanet.name} History?',
                    style: const TextStyle(color: OrbitTheme.starWhite, fontSize: 16),
                  ),
                  content: Text(
                    'This will remove all saved transmissions for ${chatState.selectedPlanet.name}.',
                    style: const TextStyle(color: OrbitTheme.starlightMuted, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel', style: TextStyle(color: OrbitTheme.starlightDark)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OrbitTheme.marsCrimson,
                        foregroundColor: OrbitTheme.starWhite,
                      ),
                      child: const Text('Clear'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(chatNotifierProvider.notifier).clearActivePlanetHistory();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${chatState.selectedPlanet.name} history cleared'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Launch 3D Universe',
            icon: const Icon(Icons.blur_on, color: OrbitTheme.earthCyan, size: 22),
            onPressed: () => context.push('/universe'),
          ),
          Builder(
            builder: (ctx) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: OpenTaskCountBadge(
                count: taskState.openTaskCount,
                onTap: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ),
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
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width > 540
            ? 480
            : MediaQuery.of(context).size.width * 0.9,
        backgroundColor: OrbitTheme.deepSpace,
        child: TaskPanel(
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: OrbitTheme.voidBlack,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: PlanetSelector(
                  selectedPlanet: chatState.selectedPlanet,
                  onPlanetSelected: (planet) {
                    ref.read(chatNotifierProvider.notifier).switchPlanet(planet);
                  },
                ),
              ),
            ),
          ),
          const Divider(color: OrbitTheme.orbitCardBorder, height: 1),

          Expanded(
            child: chatState.messages.isEmpty && !_isExtracting && _extractedDrafts == null
                ? _buildEmptyState(chatState.selectedPlanet)
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: chatState.messages.length +
                            (_isExtracting ? 1 : 0) +
                            (_extractedDrafts != null ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < chatState.messages.length) {
                            final msg = chatState.messages[index];
                            return MessageBubble(
                              message: msg,
                              currentPlanet: chatState.selectedPlanet,
                              onRetry: msg.isError
                                  ? () => ref.read(chatNotifierProvider.notifier).retryLastMessage()
                                  : null,
                              onExtractTasks: _extractTasksFromMessage,
                            );
                          } else if (_isExtracting && index == chatState.messages.length) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: OrbitTheme.orbitCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: OrbitTheme.earthCyan.withAlpha(100)),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(OrbitTheme.earthCyan),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '✦ Extracting orbital action items with planetary intelligence...',
                                    style: TextStyle(color: OrbitTheme.earthCyan, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return TaskSuggestionsCard(
                              rawDrafts: _extractedDrafts!,
                              sourceMessageId: _extractedSourceMsgId,
                              sourceConversationId: chatState.activeConversation?.id,
                              onDismiss: () => setState(() => _extractedDrafts = null),
                              onCreated: (count) {
                                setState(() => _extractedDrafts = null);
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
          ),

          _buildInputBar(chatState),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Planet planet) {
    List<String> suggestions;
    switch (planet.slug) {
      case 'coding':
        suggestions = [
          'Write a thread-safe cache in Dart',
          'Design clean architecture repository layer',
          'Debug async Stream race conditions',
        ];
        break;
      case 'creative':
        suggestions = [
          'Draft a sci-fi prologue set in orbital colonies',
          'Compose poetic copy for a deep-space observatory',
          'Brainstorm celestial world-building lore',
        ];
        break;
      case 'reasoning':
        suggestions = [
          'Deduce step-by-step logic for the Monty Hall problem',
          'Analyze architectural trade-offs: Monolith vs Serverless',
          'Evaluate Bayesian reasoning for uncertain telemetry',
        ];
        break;
      case 'research':
        suggestions = [
          'What is the latest Flutter release?',
          'Explain CRISPR gene editing mechanisms and applications',
          'Synthesize current global aerospace developments',
        ];
        break;
      default:
        suggestions = [
          'Create a step-by-step roadmap for scalable software architecture',
          'Draft a 90-day technical milestones execution plan',
          'Synthesize project requirements into a phased roadmap',
        ];
        break;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: planet.gradient),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: planet.primaryColor.withAlpha(90),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(planet.icon, color: OrbitTheme.voidBlack, size: 34),
              ),
              const SizedBox(height: 18),
              Text(
                planet.planetTitle,
                style: const TextStyle(
                  color: OrbitTheme.starWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: planet.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: planet.primaryColor.withAlpha(60)),
                ),
                child: Text(
                  planet.modelLabel,
                  style: TextStyle(
                    color: planet.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                planet.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: OrbitTheme.starlightMuted,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: suggestions.map(_suggestionChip).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestionChip(String label) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(color: OrbitTheme.starlightMuted, fontSize: 12),
      ),
      backgroundColor: OrbitTheme.orbitCard,
      side: const BorderSide(color: OrbitTheme.orbitCardBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        _inputController.text = label;
        _sendMessage();
      },
    );
  }

  Widget _buildInputBar(dynamic chatState) {
    final isStreaming = chatState.isStreaming as bool;
    final planet = chatState.selectedPlanet as Planet;

    String hintText;
    switch (planet.slug) {
      case 'coding':
        hintText = 'Transmit architecture or coding query to Mars...';
        break;
      case 'creative':
        hintText = 'Compose narrative, metaphor, or creative copy with Jupiter...';
        break;
      case 'reasoning':
        hintText = 'Present logic, trade-off, or deduction problem to Saturn...';
        break;
      case 'research':
        hintText = 'Ask Neptune for research or current events (Live Web Search)...';
        break;
      default:
        hintText = 'Transmit message across the orbit...';
        break;
    }

    return Container(
      decoration: const BoxDecoration(
        color: OrbitTheme.voidBlack,
        border: Border(top: BorderSide(color: OrbitTheme.orbitCardBorder, width: 0.5)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 16),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Unified Glassmorphic Capsule
                Container(
                  decoration: BoxDecoration(
                    color: OrbitTheme.cosmicSurface.withAlpha(230),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: planet.primaryColor.withAlpha(70),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: planet.primaryColor.withAlpha(18),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                      const BoxShadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Active Planet Indicator Pill
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7, left: 2, right: 8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: planet.primaryColor.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            planet.icon,
                            color: planet.primaryColor,
                            size: 16,
                          ),
                        ),
                      ),

                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          maxLines: 6,
                          minLines: 1,
                          style: const TextStyle(
                            color: OrbitTheme.starWhite,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: const TextStyle(
                              color: OrbitTheme.starlightDark,
                              fontSize: 13.5,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Send Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: planet.gradient),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: planet.primaryColor.withAlpha(80),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: isStreaming ? 'Processing transmission...' : 'Transmit (Enter)',
                            icon: isStreaming
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: OrbitTheme.voidBlack,
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_upward_rounded,
                                    color: OrbitTheme.voidBlack,
                                    size: 20,
                                  ),
                            onPressed: isStreaming ? null : _sendMessage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Micro Disclaimer / Status Caption
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 10, color: OrbitTheme.starlightDark.withAlpha(160)),
                    const SizedBox(width: 4),
                    Text(
                      'AI Orbit • Model: ${getCurrentModelLabel(chatState)} • Server-side Gateway Protected',
                      style: TextStyle(
                        color: OrbitTheme.starlightDark.withAlpha(180),
                        fontSize: 10.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
