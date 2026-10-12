import 'package:flutter/material.dart';
import '../../../../core/constants/orbit_theme.dart';
import '../../domain/models/task.dart';
import '../../domain/models/task_priority.dart';
import '../../domain/models/task_status.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = priority.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(120), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            priority.label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withAlpha(100), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 11, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DueDateBadge extends StatelessWidget {
  final Task task;

  const DueDateBadge({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.dueDate == null) return const SizedBox.shrink();

    final date = task.dueDate!;
    final dateStr = '${date.month}/${date.day}';

    Color textColor = OrbitTheme.starlightMuted;
    Color bgColor = OrbitTheme.voidBlack;
    Color borderColor = OrbitTheme.orbitCardBorder;
    IconData icon = Icons.event_outlined;
    String label = dateStr;

    if (task.isCompleted) {
      textColor = OrbitTheme.starlightDark;
      label = 'Done ($dateStr)';
    } else if (task.isOverdue) {
      textColor = OrbitTheme.marsCrimson;
      bgColor = OrbitTheme.marsCrimson.withAlpha(30);
      borderColor = OrbitTheme.marsCrimson.withAlpha(120);
      icon = Icons.warning_amber_rounded;
      label = 'Overdue ($dateStr)';
    } else if (task.isDueToday) {
      textColor = const Color(0xFFFF9100);
      bgColor = const Color(0xFFFF9100).withAlpha(30);
      borderColor = const Color(0xFFFF9100).withAlpha(120);
      icon = Icons.alarm;
      label = 'Due Today';
    } else if (task.isDueSoon) {
      textColor = OrbitTheme.saturnGold;
      bgColor = OrbitTheme.saturnGold.withAlpha(25);
      borderColor = OrbitTheme.saturnGold.withAlpha(100);
      icon = Icons.hourglass_bottom_rounded;
      label = 'Due $dateStr';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class OpenTaskCountBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const OpenTaskCountBadge({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: OrbitTheme.orbitCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: count > 0 ? OrbitTheme.earthCyan.withAlpha(120) : OrbitTheme.orbitCardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt,
              size: 15,
              color: count > 0 ? OrbitTheme.earthCyan : OrbitTheme.starlightDark,
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                color: count > 0 ? OrbitTheme.earthCyan : OrbitTheme.starlightDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
