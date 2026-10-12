import 'task_priority.dart';
import 'task_status.dart';

class Task {
  final String id;
  final String? workspaceId;
  final String creatorId;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final double position;
  final String? assigneeId;
  final String? assigneeEmail;
  final String? assignedAgentSlug;
  final String source; // 'manual' | 'ai'
  final String? sourceConversationId;
  final String? sourceMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    this.workspaceId,
    required this.creatorId,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.dueDate,
    this.position = 0.0,
    this.assigneeId,
    this.assigneeEmail,
    this.assignedAgentSlug,
    this.source = 'manual',
    this.sourceConversationId,
    this.sourceMessageId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  bool get isAiGenerated => source == 'ai';
  bool get isCompleted => status == TaskStatus.done;

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isDueToday {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return dueDate!.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
        dueDate!.isBefore(todayEnd.add(const Duration(seconds: 1)));
  }

  bool get isDueSoon {
    if (dueDate == null || isCompleted || isOverdue || isDueToday) return false;
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 3));
    return dueDate!.isBefore(threshold);
  }

  Task copyWith({
    String? id,
    String? workspaceId,
    String? creatorId,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    double? position,
    String? assigneeId,
    String? assigneeEmail,
    String? assignedAgentSlug,
    String? source,
    String? sourceConversationId,
    String? sourceMessageId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      position: position ?? this.position,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeEmail: assigneeEmail ?? this.assigneeEmail,
      assignedAgentSlug: assignedAgentSlug ?? this.assignedAgentSlug,
      source: source ?? this.source,
      sourceConversationId: sourceConversationId ?? this.sourceConversationId,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? '',
      workspaceId: json['workspace_id'] as String?,
      creatorId: json['creator_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: TaskPriority.fromString(json['priority'] as String?),
      status: TaskStatus.fromString(json['status'] as String?),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      position: (json['position'] as num?)?.toDouble() ?? 0.0,
      assigneeId: json['assignee_id'] as String?,
      assigneeEmail: json['assignee_email'] as String?,
      assignedAgentSlug: json['assigned_agent_slug'] as String?,
      source: json['source'] as String? ?? 'manual',
      sourceConversationId: json['source_conversation_id'] as String?,
      sourceMessageId: json['source_message_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'priority': priority.toDbString(),
      'status': status.toDbString(),
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      'position': position,
      if (assigneeId != null) 'assignee_id': assigneeId,
      if (assignedAgentSlug != null) 'assigned_agent_slug': assignedAgentSlug,
      'source': source,
      if (sourceConversationId != null)
        'source_conversation_id': sourceConversationId,
      if (sourceMessageId != null) 'source_message_id': sourceMessageId,
    };
  }
}
