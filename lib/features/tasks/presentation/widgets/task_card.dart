import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_orbit/core/constants/orbit_theme.dart';
import 'package:ai_orbit/features/chat/domain/models/planet.dart';
import 'package:ai_orbit/features/chat/presentation/chat_notifier.dart';
import 'package:ai_orbit/features/tasks/domain/models/task.dart';
import 'package:ai_orbit/features/tasks/domain/models/task_status.dart';
import 'package:ai_orbit/features/tasks/presentation/task_notifier.dart';
import 'task_badge.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  final VoidCallback? onEdit;
  final VoidCallback? onViewInChat;

  const TaskCard({
    super.key,
    required this.task,
    this.onEdit,
    this.onViewInChat,
  });

  void _cycleStatus(WidgetRef ref) {
    final nextStatus = switch (task.status) {
      TaskStatus.todo => TaskStatus.inProgress,
      TaskStatus.inProgress => TaskStatus.done,
      TaskStatus.blocked => TaskStatus.todo,
      TaskStatus.done => TaskStatus.todo,
    };
    ref.read(taskNotifierProvider.notifier).updateStatus(task.id, nextStatus);
  }

  void _askPlanetToHelp(BuildContext context, WidgetRef ref) {
    final targetPlanet = Planet.findBySlugOrName(task.assignedAgentSlug) ?? Planet.bySlug('coding');

    ref.read(chatNotifierProvider.notifier).switchPlanet(targetPlanet);

    final prompt = 'Help me solve this task: "${task.title}"\n\n'
        'Description: ${task.description.isNotEmpty ? task.description : "None provided."}\n'
        'Priority: ${task.priority.label}.';

    ref.read(chatNotifierProvider.notifier).prefillPrompt(prompt);

    Navigator.of(context).maybePop(); // Close drawer if open
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${targetPlanet.name} with task prompt prefilled!'),
        backgroundColor: targetPlanet.primaryColor.withAlpha(200),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.done;
    final planet = Planet.findBySlugOrName(task.assignedAgentSlug);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDone ? OrbitTheme.voidBlack : OrbitTheme.orbitCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isOverdue
              ? OrbitTheme.marsCrimson.withAlpha(120)
              : (isDone
                  ? OrbitTheme.orbitCardBorder.withAlpha(60)
                  : OrbitTheme.orbitCardBorder),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status Checkbox + Title + Priority Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _cycleStatus(ref),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      task.status.icon,
                      size: 20,
                      color: task.status.color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: isDone
                              ? OrbitTheme.starlightDark
                              : OrbitTheme.starWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDone
                                ? OrbitTheme.starlightDark
                                : OrbitTheme.starlightMuted,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PriorityBadge(priority: task.priority, compact: true),
              ],
            ),

            const SizedBox(height: 10),

            // Metadata Row: Due Date, Assignee/Planet, Source
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (task.dueDate != null) DueDateBadge(task: task),

                // Assignee or Planet badge
                if (planet != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: planet.primaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: planet.primaryColor.withAlpha(90)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(planet.icon, size: 12, color: planet.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          planet.name,
                          style: TextStyle(
                            color: planet.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (task.assigneeEmail != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: OrbitTheme.earthCyan.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: OrbitTheme.earthCyan.withAlpha(90)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 12, color: OrbitTheme.earthCyan),
                        const SizedBox(width: 4),
                        Text(
                          task.assigneeEmail!,
                          style: const TextStyle(
                            color: OrbitTheme.earthCyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: OrbitTheme.voidBlack,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: OrbitTheme.orbitCardBorder),
                    ),
                    child: const Text(
                      'Unassigned',
                      style: TextStyle(
                        color: OrbitTheme.starlightDark,
                        fontSize: 10,
                      ),
                    ),
                  ),

                // AI source badge
                if (task.isAiGenerated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: OrbitTheme.saturnGold.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: OrbitTheme.saturnGold.withAlpha(80)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 10, color: OrbitTheme.saturnGold),
                        SizedBox(width: 3),
                        Text(
                          'AI Orbit',
                          style: TextStyle(
                            color: OrbitTheme.saturnGold,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (task.sourceMessageId != null && onViewInChat != null)
                  InkWell(
                    onTap: onViewInChat,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, size: 12, color: OrbitTheme.earthCyan),
                        SizedBox(width: 2),
                        Text(
                          'View in chat',
                          style: TextStyle(
                            color: OrbitTheme.earthCyan,
                            fontSize: 10,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(color: OrbitTheme.orbitCardBorder, height: 1),
            const SizedBox(height: 6),

            // Bottom Actions Row: Status Selector, "Ask Planet to help", Edit, Delete
            Row(
              children: [
                // Quick Status Menu
                PopupMenuButton<TaskStatus>(
                  tooltip: 'Change Status',
                  initialValue: task.status,
                  color: OrbitTheme.deepSpace,
                  onSelected: (status) {
                    ref.read(taskNotifierProvider.notifier).updateStatus(task.id, status);
                  },
                  itemBuilder: (context) => TaskStatus.values.map((s) {
                    return PopupMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          Icon(s.icon, size: 14, color: s.color),
                          const SizedBox(width: 8),
                          Text(s.label, style: TextStyle(color: s.color, fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: OrbitTheme.orbitCardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          task.status.label,
                          style: TextStyle(color: task.status.color, fontSize: 11),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 14, color: OrbitTheme.starlightDark),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // "Ask Mars/Planet to help"
                if (!isDone)
                  TextButton.icon(
                    onPressed: () => _askPlanetToHelp(context, ref),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: planet?.primaryColor ?? OrbitTheme.marsCrimson,
                    ),
                    icon: Icon(
                      planet?.icon ?? Icons.code,
                      size: 13,
                    ),
                    label: Text(
                      'Ask ${planet?.name ?? "Mars"} to help',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),

                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16, color: OrbitTheme.starlightMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  tooltip: 'Edit task',
                  onPressed: onEdit,
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: OrbitTheme.marsCrimson),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  tooltip: 'Delete task',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: OrbitTheme.deepSpace,
                        title: const Text('Delete Task?', style: TextStyle(color: OrbitTheme.starWhite, fontSize: 16)),
                        content: Text('Remove "${task.title}" permanently?',
                            style: const TextStyle(color: OrbitTheme.starlightMuted, fontSize: 13)),
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
                            child: const Text('Delete'),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
