import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/constants/orbit_theme.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/planet.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Planet currentPlanet;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    required this.currentPlanet,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble(context);
    } else {
      return _buildAssistantBubble(context);
    }
  }

  Widget _buildUserBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 12, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: OrbitTheme.cosmicSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: OrbitTheme.orbitCardBorder),
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: OrbitTheme.starWhite,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 14,
            backgroundColor: OrbitTheme.orbitCardBorder,
            child: Icon(Icons.person, size: 16, color: OrbitTheme.starlightMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 48, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: currentPlanet.primaryColor.withAlpha(50),
            child: Icon(currentPlanet.icon, size: 16, color: currentPlanet.primaryColor),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: OrbitTheme.orbitCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: message.isError
                      ? OrbitTheme.marsCrimson.withAlpha(120)
                      : OrbitTheme.orbitCardBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.fallbackFrom != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: OrbitTheme.saturnGold.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: OrbitTheme.saturnGold.withAlpha(100)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.alt_route, size: 12, color: OrbitTheme.saturnGold),
                          const SizedBox(width: 4),
                          Text(
                            'Fallback cascaded from ${message.fallbackFrom}',
                            style: const TextStyle(
                              color: OrbitTheme.saturnGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (message.isError)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: OrbitTheme.marsCrimson, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                message.errorMessage ?? 'Transmission interrupted.',
                                style: const TextStyle(
                                  color: OrbitTheme.marsCrimson,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (onRetry != null) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: onRetry,
                            style: TextButton.styleFrom(
                              foregroundColor: OrbitTheme.earthCyan,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Retry Transmission', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ],
                    )
                  else ...[
                    MarkdownBody(
                      data: message.content.isEmpty && message.isStreaming
                          ? '✦ Awaiting orbital stream...'
                          : message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: OrbitTheme.starWhite,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        code: const TextStyle(
                          backgroundColor: OrbitTheme.voidBlack,
                          color: OrbitTheme.earthCyan,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: OrbitTheme.voidBlack,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: OrbitTheme.orbitCardBorder),
                        ),
                        h1: const TextStyle(color: OrbitTheme.starWhite, fontWeight: FontWeight.bold),
                        h2: const TextStyle(color: OrbitTheme.starWhite, fontWeight: FontWeight.bold),
                        h3: const TextStyle(color: OrbitTheme.starWhite, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (message.isStreaming)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(OrbitTheme.earthCyan),
                          ),
                        ),
                      ),
                  ],

                  if (!message.isStreaming && !message.isError && message.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, size: 14, color: OrbitTheme.starlightDark),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Copy transmission',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: message.content));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transmission copied to clipboard'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
