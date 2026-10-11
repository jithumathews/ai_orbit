import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/orbit_theme.dart';
import '../../domain/models/chat_source.dart';

class SourceCard extends StatelessWidget {
  final int index;
  final ChatSource source;

  const SourceCard({
    super.key,
    required this.index,
    required this.source,
  });

  Future<void> _openSourceUrl(BuildContext context) async {
    if (source.url.isEmpty) return;
    try {
      final uri = Uri.parse(source.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not navigate to source: ${source.url}'),
          backgroundColor: OrbitTheme.marsCrimson,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: OrbitTheme.cosmicSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OrbitTheme.orbitCardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSourceUrl(context),
          borderRadius: BorderRadius.circular(10),
          hoverColor: OrbitTheme.earthCyan.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: OrbitTheme.earthCyan.withAlpha(40),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '[$index]',
                        style: const TextStyle(
                          color: OrbitTheme.earthCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        source.domain,
                        style: const TextStyle(
                          color: OrbitTheme.starlightDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 11, color: OrbitTheme.starlightDark),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  source.title,
                  style: const TextStyle(
                    color: OrbitTheme.starWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (source.snippet.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    source.snippet,
                    style: const TextStyle(
                      color: OrbitTheme.starlightMuted,
                      fontSize: 10,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
