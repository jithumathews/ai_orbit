import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_orbit/core/constants/orbit_theme.dart';
import 'package:ai_orbit/features/chat/domain/models/planet.dart';
import 'package:ai_orbit/features/tasks/domain/models/task.dart';
import 'package:ai_orbit/features/tasks/domain/models/task_priority.dart';
import 'package:ai_orbit/features/tasks/presentation/task_notifier.dart';
import 'package:ai_orbit/features/tasks/presentation/workspace_notifier.dart';

class TaskSuggestionItem {
  String title;
  String description;
  TaskPriority priority;
  DateTime? dueDate;
  String? assignedAgentSlug;
  String? assigneeId;
  String? assigneeLabel;
  bool isSelected;

  TaskSuggestionItem({
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.assignedAgentSlug,
    this.assigneeId,
    this.assigneeLabel,
    this.isSelected = true,
  });

  factory TaskSuggestionItem.fromMap(Map<String, dynamic> map) {
    return TaskSuggestionItem(
      title: map['title'] as String? ?? 'New Orbital Task',
      description: map['description'] as String? ?? '',
      priority: TaskPriority.fromString(map['priority'] as String?),
      dueDate: map['due_date'] != null
          ? DateTime.tryParse(map['due_date'] as String)
          : null,
      assignedAgentSlug: map['assigned_agent_slug'] as String?,
      assigneeId: map['assignee_id'] as String?,
      assigneeLabel: map['assignee_label'] as String?,
      isSelected: true,
    );
  }
}

class TaskSuggestionsCard extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> rawDrafts;
  final String? sourceMessageId;
  final String? sourceConversationId;
  final VoidCallback onDismiss;
  final void Function(int createdCount)? onCreated;

  const TaskSuggestionsCard({
    super.key,
    required this.rawDrafts,
    this.sourceMessageId,
    this.sourceConversationId,
    required this.onDismiss,
    this.onCreated,
  });

  @override
  ConsumerState<TaskSuggestionsCard> createState() =>
      _TaskSuggestionsCardState();
}

class _TaskSuggestionsCardState extends ConsumerState<TaskSuggestionsCard> {
  late List<TaskSuggestionItem> _items;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _items = widget.rawDrafts.map((d) => TaskSuggestionItem.fromMap(d)).toList();
  }

  Future<void> _createSelected() async {
    final selected = _items.where((i) => i.isSelected && i.title.trim().isNotEmpty).toList();
    if (selected.isEmpty) return;

    setState(() => _isCreating = true);

    try {
      final activeWsId = ref.read(workspaceNotifierProvider).activeWorkspace?.id;
      final currentUserId = ref.read(taskNotifierProvider.notifier).currentUserId ?? 'orbit-user';

      final tasksToCreate = selected.map((item) {
        return Task(
          id: '',
          workspaceId: activeWsId,
          creatorId: currentUserId,
          title: item.title.trim(),
          description: item.description,
          priority: item.priority,
          dueDate: item.dueDate,
          assignedAgentSlug: item.assignedAgentSlug,
          assigneeId: item.assigneeId,
          source: 'ai',
          sourceMessageId: widget.sourceMessageId,
          sourceConversationId: widget.sourceConversationId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      final createdTasks = await ref.read(taskNotifierProvider.notifier).createTasksBatch(tasksToCreate);

      if (!mounted) return;
      setState(() => _isCreating = false);

      if (createdTasks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No orbital tasks could be created. Please verify your connection.'),
            backgroundColor: OrbitTheme.marsCrimson,
          ),
        );
      } else {
        widget.onCreated?.call(createdTasks.length);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully created ${createdTasks.length} orbital task${createdTasks.length == 1 ? '' : 's'}!'),
            backgroundColor: OrbitTheme.neptuneEmerald,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create tasks: $e'),
          backgroundColor: OrbitTheme.marsCrimson,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: OrbitTheme.voidBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: OrbitTheme.orbitCardBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: OrbitTheme.starlightDark),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'No action items found in this transmission.',
                style: TextStyle(color: OrbitTheme.starlightMuted, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: widget.onDismiss,
              child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    final selectedCount = _items.where((i) => i.isSelected).length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: OrbitTheme.deepSpace,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OrbitTheme.earthCyan.withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: OrbitTheme.earthCyan.withAlpha(20),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: OrbitTheme.earthCyan.withAlpha(20),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: OrbitTheme.earthCyan),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'PROPOSED ORBITAL TASKS (CONFIRMATION)',
                    style: TextStyle(
                      color: OrbitTheme.earthCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: OrbitTheme.starlightDark),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Dismiss suggestions',
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
          ),

          // Items List
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(_items.length, (idx) {
                final item = _items[idx];
                final planet = Planet.findBySlugOrName(item.assignedAgentSlug);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.isSelected
                        ? OrbitTheme.voidBlack
                        : OrbitTheme.voidBlack.withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.isSelected
                          ? OrbitTheme.orbitCardBorder
                          : OrbitTheme.orbitCardBorder.withAlpha(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: item.isSelected,
                            activeColor: OrbitTheme.earthCyan,
                            checkColor: OrbitTheme.voidBlack,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              setState(() {
                                item.isSelected = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: item.title,
                              style: TextStyle(
                                color: item.isSelected
                                    ? OrbitTheme.starWhite
                                    : OrbitTheme.starlightDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 4),
                                border: InputBorder.none,
                              ),
                              onChanged: (val) {
                                item.title = val;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Priority selector dropdown
                          PopupMenuButton<TaskPriority>(
                            tooltip: 'Change Priority',
                            initialValue: item.priority,
                            color: OrbitTheme.deepSpace,
                            onSelected: (p) => setState(() => item.priority = p),
                            itemBuilder: (context) => TaskPriority.values.map((p) {
                              return PopupMenuItem(
                                value: p,
                                child: Text(p.label, style: TextStyle(color: p.color, fontSize: 12)),
                              );
                            }).toList(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.priority.color.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: item.priority.color.withAlpha(100)),
                              ),
                              child: Text(
                                item.priority.label.toUpperCase(),
                                style: TextStyle(
                                  color: item.priority.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Sub-row: Assignee or Planet chip
                      Padding(
                        padding: const EdgeInsets.only(left: 36, top: 4),
                        child: Row(
                          children: [
                            if (planet != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: planet.primaryColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(planet.icon, size: 10, color: planet.primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      planet.name,
                                      style: TextStyle(color: planet.primaryColor, fontSize: 10),
                                    ),
                                  ],
                                ),
                              )
                            else if (item.assigneeLabel != null)
                              Text(
                                'Assignee: ${item.assigneeLabel}',
                                style: const TextStyle(color: OrbitTheme.starlightMuted, fontSize: 10),
                              ),
                            if (item.dueDate != null) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.event, size: 11, color: OrbitTheme.starlightDark),
                              const SizedBox(width: 3),
                              Text(
                                '${item.dueDate!.month}/${item.dueDate!.day}',
                                style: const TextStyle(color: OrbitTheme.starlightMuted, fontSize: 10),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Action Buttons: Create Selected / Dismiss
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isCreating ? null : widget.onDismiss,
                  child: const Text('Dismiss', style: TextStyle(color: OrbitTheme.starlightDark, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrbitTheme.earthCyan,
                    foregroundColor: OrbitTheme.voidBlack,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: _isCreating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(OrbitTheme.voidBlack),
                          ),
                        )
                      : const Icon(Icons.check, size: 15),
                  label: Text(
                    'Confirm & Create ($selectedCount)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isCreating || selectedCount == 0 ? null : _createSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
