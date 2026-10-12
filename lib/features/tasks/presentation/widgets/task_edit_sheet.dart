import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_orbit/core/constants/orbit_theme.dart';
import 'package:ai_orbit/features/chat/domain/models/planet.dart';
import 'package:ai_orbit/features/tasks/domain/models/task.dart';
import 'package:ai_orbit/features/tasks/domain/models/task_priority.dart';
import 'package:ai_orbit/features/tasks/domain/models/task_status.dart';
import 'package:ai_orbit/features/tasks/presentation/task_notifier.dart';
import 'package:ai_orbit/features/tasks/presentation/workspace_notifier.dart';

class TaskEditSheet extends ConsumerStatefulWidget {
  final Task? taskToEdit;
  final String? initialTitle;
  final String? initialDescription;
  final TaskPriority? initialPriority;
  final String? initialAgentSlug;
  final DateTime? initialDueDate;
  final String? sourceMessageId;
  final String? sourceConversationId;
  final String? source;

  const TaskEditSheet({
    super.key,
    this.taskToEdit,
    this.initialTitle,
    this.initialDescription,
    this.initialPriority,
    this.initialAgentSlug,
    this.initialDueDate,
    this.sourceMessageId,
    this.sourceConversationId,
    this.source,
  });

  @override
  ConsumerState<TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends ConsumerState<TaskEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _dueDate;
  String? _assigneeId;
  String? _assignedAgentSlug;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.taskToEdit;
    _titleController = TextEditingController(
      text: t?.title ?? widget.initialTitle ?? '',
    );
    _descController = TextEditingController(
      text: t?.description ?? widget.initialDescription ?? '',
    );
    _priority = t?.priority ?? widget.initialPriority ?? TaskPriority.medium;
    _status = t?.status ?? TaskStatus.todo;
    _dueDate = t?.dueDate ?? widget.initialDueDate;
    _assigneeId = t?.assigneeId;
    _assignedAgentSlug = t?.assignedAgentSlug ?? widget.initialAgentSlug;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 1)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: OrbitTheme.earthCyan,
              onPrimary: OrbitTheme.voidBlack,
              surface: OrbitTheme.deepSpace,
              onSurface: OrbitTheme.starWhite,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: OrbitTheme.deepSpace,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (widget.taskToEdit != null) {
      // Update existing
      final updated = widget.taskToEdit!.copyWith(
        title: title,
        description: description,
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
        assigneeId: _assigneeId,
        assignedAgentSlug: _assignedAgentSlug,
      );
      final success = await ref.read(taskNotifierProvider.notifier).updateTask(updated);
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) Navigator.of(context).pop(updated);
      }
    } else {
      // Create new
      final created = await ref.read(taskNotifierProvider.notifier).createTask(
        title: title,
        description: description,
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
        assigneeId: _assigneeId,
        assignedAgentSlug: _assignedAgentSlug,
        source: widget.source ?? 'manual',
        sourceConversationId: widget.sourceConversationId,
        sourceMessageId: widget.sourceMessageId,
      );
      if (mounted) {
        setState(() => _isSaving = false);
        if (created != null) Navigator.of(context).pop(created);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    final wsState = ref.watch(workspaceNotifierProvider);
    final members = wsState.members;
    final currentUserId = ref.read(taskNotifierProvider.notifier).currentUserId;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: OrbitTheme.deepSpace,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: OrbitTheme.orbitCardBorder)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isEditing ? Icons.edit_note : Icons.add_task,
                        color: OrbitTheme.earthCyan,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'Edit Orbital Task' : 'New Orbital Task',
                        style: const TextStyle(
                          color: OrbitTheme.starWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: OrbitTheme.starlightDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title input
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                style: const TextStyle(color: OrbitTheme.starWhite, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Task Title *',
                  labelStyle: const TextStyle(color: OrbitTheme.starlightMuted),
                  hintText: 'e.g., Audit RLS policies on chat_history',
                  hintStyle: const TextStyle(color: OrbitTheme.starlightDark, fontSize: 13),
                  filled: true,
                  fillColor: OrbitTheme.voidBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: OrbitTheme.orbitCardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: OrbitTheme.orbitCardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: OrbitTheme.earthCyan),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  if (val.trim().length > 100) {
                    return 'Title cannot exceed 100 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Description input
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: OrbitTheme.starWhite, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: const TextStyle(color: OrbitTheme.starlightMuted),
                  hintText: 'Add mission context, reproduction steps, or requirements...',
                  hintStyle: const TextStyle(color: OrbitTheme.starlightDark, fontSize: 12),
                  filled: true,
                  fillColor: OrbitTheme.voidBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: OrbitTheme.orbitCardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: OrbitTheme.orbitCardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: OrbitTheme.earthCyan),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Priority Selector
              const Text(
                'PRIORITY',
                style: TextStyle(
                  color: OrbitTheme.starlightDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((p) {
                  final isSelected = _priority == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => setState(() => _priority = p),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? p.color.withAlpha(40) : OrbitTheme.voidBlack,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? p.color : OrbitTheme.orbitCardBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p.label,
                            style: TextStyle(
                              color: isSelected ? p.color : OrbitTheme.starlightMuted,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Status Selector (if editing)
              if (isEditing) ...[
                const Text(
                  'STATUS',
                  style: TextStyle(
                    color: OrbitTheme.starlightDark,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: TaskStatus.values.map((s) {
                    final isSelected = _status == s;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: () => setState(() => _status = s),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? s.color.withAlpha(35) : OrbitTheme.voidBlack,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? s.color : OrbitTheme.orbitCardBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              s.label,
                              style: TextStyle(
                                color: isSelected ? s.color : OrbitTheme.starlightMuted,
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Due Date Picker Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DUE DATE',
                    style: TextStyle(
                      color: OrbitTheme.starlightDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (_dueDate != null)
                    TextButton(
                      onPressed: () => setState(() => _dueDate = null),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Clear', style: TextStyle(color: OrbitTheme.marsCrimson, fontSize: 11)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: OrbitTheme.voidBlack,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: OrbitTheme.orbitCardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: OrbitTheme.earthCyan),
                      const SizedBox(width: 10),
                      Text(
                        _dueDate != null
                            ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                            : 'Set due date (optional)',
                        style: TextStyle(
                          color: _dueDate != null ? OrbitTheme.starWhite : OrbitTheme.starlightDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Assignment Section (Team Member or Planet Specialist)
              const Text(
                'ASSIGNMENT',
                style: TextStyle(
                  color: OrbitTheme.starlightDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Planet Personas
              const Text(
                'Assign to Planet Specialist:',
                style: TextStyle(color: OrbitTheme.starlightMuted, fontSize: 11),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _assignedAgentSlug = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: _assignedAgentSlug == null ? OrbitTheme.earthCyan.withAlpha(30) : OrbitTheme.voidBlack,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _assignedAgentSlug == null ? OrbitTheme.earthCyan : OrbitTheme.orbitCardBorder,
                          ),
                        ),
                        child: const Text('None', style: TextStyle(color: OrbitTheme.starlightMuted, fontSize: 11)),
                      ),
                    ),
                    ...Planet.availablePlanets.map((p) {
                      final isSelected = _assignedAgentSlug == p.slug;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _assignedAgentSlug = isSelected ? null : p.slug;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? p.primaryColor.withAlpha(40) : OrbitTheme.voidBlack,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? p.primaryColor : OrbitTheme.orbitCardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(p.icon, size: 13, color: p.primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                p.name,
                                style: TextStyle(
                                  color: isSelected ? p.primaryColor : OrbitTheme.starlightMuted,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Team Members
              const Text(
                'Or assign to Team Member:',
                style: TextStyle(color: OrbitTheme.starlightMuted, fontSize: 11),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Myself chip
                    InkWell(
                      onTap: () {
                        setState(() {
                          _assigneeId = _assigneeId == currentUserId ? null : currentUserId;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: _assigneeId == currentUserId ? OrbitTheme.earthCyan.withAlpha(40) : OrbitTheme.voidBlack,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _assigneeId == currentUserId ? OrbitTheme.earthCyan : OrbitTheme.orbitCardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person, size: 13, color: OrbitTheme.earthCyan),
                            const SizedBox(width: 4),
                            Text(
                              'Assign to Myself',
                              style: TextStyle(
                                color: _assigneeId == currentUserId ? OrbitTheme.earthCyan : OrbitTheme.starlightMuted,
                                fontSize: 11,
                                fontWeight: _assigneeId == currentUserId ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Workspace members
                    ...members.map((m) {
                      if (m.userId == currentUserId) return const SizedBox.shrink();
                      final isSelected = _assigneeId == m.userId;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _assigneeId = isSelected ? null : m.userId;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? OrbitTheme.earthCyan.withAlpha(40) : OrbitTheme.voidBlack,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? OrbitTheme.earthCyan : OrbitTheme.orbitCardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_outline, size: 13, color: OrbitTheme.starlightMuted),
                              const SizedBox(width: 4),
                              Text(
                                m.email,
                                style: TextStyle(
                                  color: isSelected ? OrbitTheme.earthCyan : OrbitTheme.starlightMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrbitTheme.earthCyan,
                    foregroundColor: OrbitTheme.voidBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(OrbitTheme.voidBlack),
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Orbital Task' : 'Confirm & Create Task',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
