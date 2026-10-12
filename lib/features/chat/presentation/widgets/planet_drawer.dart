import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/orbit_theme.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/planet.dart';

class PlanetDrawer extends StatelessWidget {
  final List<Conversation> conversations;
  final String? activeConversationId;
  final String? userEmail;
  final bool isMockMode;
  final ValueChanged<Conversation> onSelectConversation;
  final VoidCallback onNewTransmission;
  final VoidCallback onOpenObservatory;
  final VoidCallback onSignOut;

  const PlanetDrawer({
    super.key,
    required this.conversations,
    required this.activeConversationId,
    required this.userEmail,
    required this.isMockMode,
    required this.onSelectConversation,
    required this.onNewTransmission,
    required this.onOpenObservatory,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: OrbitTheme.deepSpace,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [OrbitTheme.earthCyan, OrbitTheme.jupiterViolet],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.blur_circular, color: OrbitTheme.voidBlack, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI ORBIT',
                        style: TextStyle(
                          color: OrbitTheme.starWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Riverpod + Clean Arch Core',
                        style: TextStyle(
                          color: OrbitTheme.starlightMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: OrbitTheme.orbitCardBorder, height: 1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onNewTransmission();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrbitTheme.orbitCard,
                  foregroundColor: OrbitTheme.earthCyan,
                  side: const BorderSide(color: OrbitTheme.earthCyan, width: 1),
                  minimumSize: const Size.fromHeight(44),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Orbital Transmission'),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/universe');
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tileColor: OrbitTheme.orbitCard,
                leading: const Icon(Icons.blur_on, color: OrbitTheme.earthCyan, size: 20),
                title: const Text(
                  '3D Universe View',
                  style: TextStyle(color: OrbitTheme.starWhite, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right, color: OrbitTheme.starlightDark, size: 18),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/tasks');
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tileColor: OrbitTheme.orbitCard,
                leading: const Icon(Icons.assignment_turned_in_outlined, color: OrbitTheme.earthCyan, size: 20),
                title: const Text(
                  'Orbital Tasks',
                  style: TextStyle(color: OrbitTheme.starWhite, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right, color: OrbitTheme.starlightDark, size: 18),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  onOpenObservatory();
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tileColor: OrbitTheme.orbitCard,
                leading: const Icon(Icons.insights, color: OrbitTheme.saturnGold, size: 20),
                title: const Text(
                  'Observatory & Quota',
                  style: TextStyle(color: OrbitTheme.starWhite, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right, color: OrbitTheme.starlightDark, size: 18),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'TRANSMISSION LOGS (${conversations.length})',
                  style: const TextStyle(
                    color: OrbitTheme.starlightDark,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            Expanded(
              child: conversations.isEmpty
                  ? const Center(
                      child: Text(
                        'No prior transmissions logged.',
                        style: TextStyle(color: OrbitTheme.starlightDark, fontSize: 12),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: conversations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final conv = conversations[index];
                        final isSelected = conv.id == activeConversationId;
                        final planet = Planet.bySlug(conv.agentSlug);

                        return ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            onSelectConversation(conv);
                          },
                          dense: true,
                          selected: isSelected,
                          selectedTileColor: planet.primaryColor.withAlpha(30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? planet.primaryColor : Colors.transparent,
                            ),
                          ),
                          leading: Icon(planet.icon, size: 16, color: planet.primaryColor),
                          title: Text(
                            conv.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? OrbitTheme.starWhite : OrbitTheme.starlightMuted,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(color: OrbitTheme.orbitCardBorder, height: 1),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: OrbitTheme.cosmicSurface,
                    child: Text(
                      (userEmail ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: OrbitTheme.earthCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userEmail ?? 'Orbital Explorer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: OrbitTheme.starWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          isMockMode ? 'Simulated Offline Mode' : 'Connected to Gateway',
                          style: TextStyle(
                            color: isMockMode ? OrbitTheme.saturnGold : OrbitTheme.neptuneEmerald,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 18, color: OrbitTheme.starlightDark),
                    tooltip: 'Sign Out',
                    onPressed: () {
                      Navigator.pop(context);
                      onSignOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
