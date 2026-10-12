import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_orbit/core/constants/orbit_theme.dart';
import 'package:ai_orbit/features/chat/domain/models/planet.dart';
import 'package:ai_orbit/features/tasks/data/task_repository.dart';
import 'package:ai_orbit/features/tasks/domain/models/task.dart';
import 'package:ai_orbit/features/tasks/domain/models/task_priority.dart';
import 'package:ai_orbit/features/tasks/domain/models/task_status.dart';
import 'package:ai_orbit/features/tasks/domain/models/workspace.dart';
import 'package:ai_orbit/features/tasks/presentation/task_notifier.dart';
import 'package:ai_orbit/features/tasks/presentation/workspace_notifier.dart';
import 'kanban_view.dart';
import 'task_card.dart';
import 'task_edit_sheet.dart';
import 'task_suggestions_card.dart';

class TaskPanel extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const TaskPanel({super.key, this.onClose});

  @override
  ConsumerState<TaskPanel> createState() => _TaskPanelState();
}

class _TaskPanelState extends ConsumerState<TaskPanel> {
  final TextEditingController _quickAddController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>>? _quickAddDrafts;
  bool _isQuickAdding = false;

  @override
  void dispose() {
    _quickAddController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleQuickAdd() async {
    final text = _quickAddController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isQuickAdding = true);
    final wsState = ref.read(workspaceNotifierProvider);
    final repo = ref.read(taskRepositoryProvider);

    try {
      final drafts = await repo.parseTasksFromText(
        text: text,
        workspaceId: wsState.activeWorkspace?.id,
      );
      if (mounted) {
        setState(() {
          _isQuickAdding = false;
          _quickAddDrafts = drafts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isQuickAdding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to parse task with AI: $e'),
            backgroundColor: OrbitTheme.marsCrimson,
          ),
        );
      }
    }
  }

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const TaskEditSheet(),
    );
  }

  void _openEditSheet(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskEditSheet(taskToEdit: task),
    );
  }

  void _showCreateWorkspaceDialog() {
    final nameCtrl = TextEditingController();
    final slugCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OrbitTheme.deepSpace,
        title: const Text('Create New Workspace', style: TextStyle(color: OrbitTheme.starWhite, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(color: OrbitTheme.starWhite, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Workspace Name',
                hintText: 'e.g. Starship Engineering',
              ),
              onChanged: (val) {
                slugCtrl.text = val.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: slugCtrl,
              style: const TextStyle(color: OrbitTheme.starWhite, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Workspace Slug',
                hintText: 'e.g. starship-engineering',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: OrbitTheme.starlightDark)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OrbitTheme.earthCyan,
              foregroundColor: OrbitTheme.voidBlack,
            ),
            child: const Text('Create'),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final slug = slugCtrl.text.trim();
              if (name.isNotEmpty && slug.isNotEmpty) {
                Navigator.pop(ctx);
                await ref.read(workspaceNotifierProvider.notifier).createWorkspace(name, slug);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog() {
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OrbitTheme.deepSpace,
        title: const Text('Invite Team Member', style: TextStyle(color: OrbitTheme.starWhite, fontSize: 16)),
        content: TextField(
          controller: emailCtrl,
          autofocus: true,
          style: const TextStyle(color: OrbitTheme.starWhite, fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'Member Email',
            hintText: 'colleague@company.com',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: OrbitTheme.starlightDark)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OrbitTheme.earthCyan,
              foregroundColor: OrbitTheme.voidBlack,
            ),
            child: const Text('Invite'),
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(ctx);
                final ok = await ref.read(workspaceNotifierProvider.notifier).inviteMember(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Invited $email to workspace' : 'Failed to invite member'),
                      backgroundColor: ok ? OrbitTheme.neptuneEmerald : OrbitTheme.marsCrimson,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);
    final wsState = ref.watch(workspaceNotifierProvider);
    final currentUserId = ref.read(taskNotifierProvider.notifier).currentUserId;

    return Container(
      color: OrbitTheme.deepSpace,
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: OrbitTheme.voidBlack,
              border: Border(bottom: BorderSide(color: OrbitTheme.orbitCardBorder)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment_turned_in_outlined, color: OrbitTheme.earthCyan, size: 20),
                    const SizedBox(width: 8),

                    // Workspace Dropdown
                    if (wsState.workspaces.isNotEmpty)
                      PopupMenuButton<Workspace>(
                        tooltip: 'Select Workspace',
                        initialValue: wsState.activeWorkspace,
                        color: OrbitTheme.deepSpace,
                        onSelected: (ws) {
                          ref.read(workspaceNotifierProvider.notifier).selectWorkspace(ws);
                          ref.read(taskNotifierProvider.notifier).bootstrap();
                        },
                        itemBuilder: (context) => [
                          ...wsState.workspaces.map((ws) => PopupMenuItem(
                                value: ws,
                                child: Row(
                                  children: [
                                    const Icon(Icons.workspaces_outlined, size: 14, color: OrbitTheme.earthCyan),
                                    const SizedBox(width: 8),
                                    Text(ws.name, style: const TextStyle(color: OrbitTheme.starWhite, fontSize: 13)),
                                  ],
                                ),
                              )),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            onTap: _showCreateWorkspaceDialog,
                            child: const Row(
                              children: [
                                Icon(Icons.add, size: 14, color: OrbitTheme.earthCyan),
                                SizedBox(width: 8),
                                Text('New Workspace...', style: TextStyle(color: OrbitTheme.earthCyan, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              wsState.activeWorkspace?.name ?? 'Personal Orbit',
                              style: const TextStyle(
                                color: OrbitTheme.starWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: OrbitTheme.starlightDark, size: 18),
                          ],
                        ),
                      )
                    else
                      const Text(
                        'ORBITAL TASKS',
                        style: TextStyle(color: OrbitTheme.starWhite, fontWeight: FontWeight.bold, fontSize: 14),
                      ),

                    const SizedBox(width: 6),

                    // Open Task Count Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: OrbitTheme.earthCyan.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: OrbitTheme.earthCyan.withAlpha(80)),
                      ),
                      child: Text(
                        '${taskState.openTaskCount} open',
                        style: const TextStyle(
                          color: OrbitTheme.earthCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Invite Member Button
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1_outlined, size: 18, color: OrbitTheme.starlightMuted),
                      tooltip: 'Invite team member',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: _showInviteMemberDialog,
                    ),

                    // Toggle View Mode (List vs Kanban)
                    IconButton(
                      icon: Icon(
                        taskState.viewMode == TaskViewMode.list ? Icons.view_kanban_outlined : Icons.view_list_outlined,
                        size: 20,
                        color: OrbitTheme.starlightMuted,
                      ),
                      tooltip: taskState.viewMode == TaskViewMode.list ? 'Switch to Kanban' : 'Switch to List',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: () {
                        ref.read(taskNotifierProvider.notifier).toggleViewMode();
                      },
                    ),

                    // New Task Button
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 22, color: OrbitTheme.earthCyan),
                      tooltip: 'Create new task',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      onPressed: _openCreateSheet,
                    ),

                    if (widget.onClose != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: OrbitTheme.starlightDark),
                        tooltip: 'Close task panel',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: widget.onClose,
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Phase 4b: "Add with AI" Quick Add Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: OrbitTheme.deepSpace,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: OrbitTheme.orbitCardBorder),
                        ),
                        child: TextField(
                          controller: _quickAddController,
                          style: const TextStyle(color: OrbitTheme.starWhite, fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: 'Add with AI: e.g. "Fix quota RPC by Friday, urgent, assign to Mars"',
                            hintStyle: TextStyle(color: OrbitTheme.starlightDark, fontSize: 11),
                            prefixIcon: Icon(Icons.auto_awesome, size: 14, color: OrbitTheme.saturnGold),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _handleQuickAdd(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OrbitTheme.saturnGold,
                        foregroundColor: OrbitTheme.voidBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        minimumSize: const Size(60, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isQuickAdding ? null : _handleQuickAdd,
                      child: _isQuickAdding
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(OrbitTheme.voidBlack),
                              ),
                            )
                          : const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Render AI Quick Add Suggestions Card if available
          if (_quickAddDrafts != null && _quickAddDrafts!.isNotEmpty)
            TaskSuggestionsCard(
              rawDrafts: _quickAddDrafts!,
              onDismiss: () {
                setState(() => _quickAddDrafts = null);
              },
              onCreated: (count) {
                setState(() {
                  _quickAddDrafts = null;
                  _quickAddController.clear();
                });
              },
            ),

          // Filter Row: Search & Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: OrbitTheme.voidBlack,
              border: Border(bottom: BorderSide(color: OrbitTheme.orbitCardBorder)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Assignee Filters
                  _buildFilterChip(
                    label: 'All',
                    isSelected: taskState.filterAssignee == null && taskState.filterPlanet == null,
                    onTap: () {
                      ref.read(taskNotifierProvider.notifier).setAssigneeFilter(null);
                      ref.read(taskNotifierProvider.notifier).setPlanetFilter(null);
                    },
                  ),
                  _buildFilterChip(
                    label: 'Assigned to Me',
                    icon: Icons.person,
                    isSelected: taskState.filterAssignee == 'me',
                    onTap: () {
                      ref.read(taskNotifierProvider.notifier).setAssigneeFilter(
                            taskState.filterAssignee == 'me' ? null : 'me',
                          );
                    },
                  ),
                  _buildFilterChip(
                    label: 'Unassigned',
                    isSelected: taskState.filterAssignee == 'unassigned',
                    onTap: () {
                      ref.read(taskNotifierProvider.notifier).setAssigneeFilter(
                            taskState.filterAssignee == 'unassigned' ? null : 'unassigned',
                          );
                    },
                  ),

                  // Planet filters
                  ...Planet.availablePlanets.take(3).map((p) {
                    final isSel = taskState.filterPlanet == p.slug;
                    return _buildFilterChip(
                      label: p.name,
                      icon: p.icon,
                      color: p.primaryColor,
                      isSelected: isSel,
                      onTap: () {
                        ref.read(taskNotifierProvider.notifier).setPlanetFilter(
                              isSel ? null : p.slug,
                            );
                      },
                    );
                  }),

                  const SizedBox(width: 8),
                  Container(width: 1, height: 16, color: OrbitTheme.orbitCardBorder),
                  const SizedBox(width: 8),

                  // Priority filters
                  ...TaskPriority.values.map((p) {
                    final isSel = taskState.filterPriority == p;
                    return _buildFilterChip(
                      label: p.label,
                      color: p.color,
                      isSelected: isSel,
                      onTap: () {
                        ref.read(taskNotifierProvider.notifier).setPriorityFilter(
                              isSel ? null : p,
                            );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          // Content: List View or Kanban View
          Expanded(
            child: taskState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(OrbitTheme.earthCyan),
                    ),
                  )
                : (taskState.viewMode == TaskViewMode.kanban
                    ? const KanbanView()
                    : _buildGroupedListView(context, taskState, currentUserId)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? OrbitTheme.earthCyan;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? chipColor.withAlpha(35) : OrbitTheme.voidBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? chipColor : OrbitTheme.orbitCardBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 11, color: isSelected ? chipColor : OrbitTheme.starlightDark),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? chipColor : OrbitTheme.starlightMuted,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedListView(BuildContext context, TaskState state, String? currentUserId) {
    final hasAnyTasks = state.tasks.isNotEmpty;
    if (!hasAnyTasks) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch_outlined, size: 40, color: OrbitTheme.starlightDark),
            const SizedBox(height: 12),
            const Text(
              'No tasks in orbital trajectory',
              style: TextStyle(color: OrbitTheme.starWhite, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Create a task manually or type in the "Add with AI" input above.',
              style: TextStyle(color: OrbitTheme.starlightMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: OrbitTheme.earthCyan,
                foregroundColor: OrbitTheme.voidBlack,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Create First Task'),
              onPressed: _openCreateSheet,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: TaskStatus.values.map((status) {
        final tasks = state.tasksForStatus(status, currentUserId: currentUserId);
        if (tasks.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  Icon(status.icon, size: 14, color: status.color),
                  const SizedBox(width: 6),
                  Text(
                    status.label.toUpperCase(),
                    style: TextStyle(
                      color: status.color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: status.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${tasks.length}',
                      style: TextStyle(
                        color: status.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...tasks.map((task) => TaskCard(
                  task: task,
                  onEdit: () => _openEditSheet(task),
                  onViewInChat: () {
                    // Navigate to chat or highlight
                    if (widget.onClose != null) widget.onClose!();
                  },
                )),
          ],
        );
      }).toList(),
    );
  }
}
