import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_orbit/core/constants/orbit_theme.dart';
import 'package:ai_orbit/features/tasks/domain/models/task.dart';
import 'package:ai_orbit/features/tasks/domain/models/task_status.dart';
import 'package:ai_orbit/features/tasks/presentation/task_notifier.dart';
import 'task_card.dart';
import 'task_edit_sheet.dart';

class KanbanView extends ConsumerWidget {
  const KanbanView({super.key});

  void _openCreateSheet(BuildContext context, TaskStatus status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskEditSheet(),
    );
  }

  void _openEditSheet(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskEditSheet(taskToEdit: task),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskNotifierProvider);
    final currentUserId = ref.read(taskNotifierProvider.notifier).currentUserId;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth > 900)
            ? (constraints.maxWidth - 48) / 4
            : 280.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: TaskStatus.values.map((status) {
              final tasksInColumn = taskState.tasksForStatus(status, currentUserId: currentUserId);

              return Container(
                width: columnWidth,
                margin: const EdgeInsets.only(right: 12),
                child: DragTarget<Task>(
                  onWillAcceptWithDetails: (details) => details.data.status != status,
                  onAcceptWithDetails: (details) {
                    final droppedTask = details.data;
                    ref.read(taskNotifierProvider.notifier).updateStatus(droppedTask.id, status);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHighlighted = candidateData.isNotEmpty;

                    return Container(
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? status.color.withAlpha(25)
                            : OrbitTheme.voidBlack.withAlpha(160),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isHighlighted
                              ? status.color
                              : OrbitTheme.orbitCardBorder,
                          width: isHighlighted ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Column Header
                          Row(
                            children: [
                              Icon(status.icon, size: 15, color: status.color),
                              const SizedBox(width: 6),
                              Text(
                                status.label.toUpperCase(),
                                style: TextStyle(
                                  color: status.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: status.color.withAlpha(30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${tasksInColumn.length}',
                                  style: TextStyle(
                                    color: status.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16, color: OrbitTheme.starlightDark),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                tooltip: 'Add to ${status.label}',
                                onPressed: () => _openCreateSheet(context, status),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          const Divider(color: OrbitTheme.orbitCardBorder, height: 1),
                          const SizedBox(height: 8),

                          // Tasks in Column
                          if (tasksInColumn.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 36),
                              alignment: Alignment.center,
                              child: Text(
                                'No tasks in ${status.label}',
                                style: const TextStyle(
                                  color: OrbitTheme.starlightDark,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            ...tasksInColumn.map((task) {
                              return Draggable<Task>(
                                data: task,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: columnWidth,
                                    child: Opacity(
                                      opacity: 0.85,
                                      child: TaskCard(task: task),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: TaskCard(task: task),
                                ),
                                child: TaskCard(
                                  task: task,
                                  onEdit: () => _openEditSheet(context, task),
                                ),
                              );
                            }),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
