import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../chat/domain/models/planet.dart';
import '../domain/models/task.dart';
import '../domain/models/task_priority.dart';
import '../domain/models/task_status.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return TaskRepository(authRepo);
});

class TaskRepository {
  final AuthRepository _auth;

  final List<Task> _mockTasks = [
    Task(
      id: 'task-demo-1',
      workspaceId: 'ws-demo-constellation',
      creatorId: 'orbit-explorer-001',
      title: 'Initialize Cybertron telemetry subsystem',
      description: 'Set up logging and telemetry pipeline for Mars coder agent.',
      priority: TaskPriority.urgent,
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      position: 1000.0,
      assignedAgentSlug: 'mars',
      source: 'ai',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Task(
      id: 'task-demo-2',
      workspaceId: 'ws-demo-constellation',
      creatorId: 'orbit-explorer-001',
      title: 'Review Earth roadmap specifications',
      description: 'Ensure all milestone checkpoints align with Q4 orbit release.',
      priority: TaskPriority.high,
      status: TaskStatus.todo,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      position: 2000.0,
      assignedAgentSlug: 'earth',
      source: 'manual',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Task(
      id: 'task-demo-3',
      workspaceId: 'ws-demo-constellation',
      creatorId: 'orbit-explorer-001',
      title: 'Audit chat_history row-level security policies',
      description: 'Confirm user isolation across multi-user sessions.',
      priority: TaskPriority.medium,
      status: TaskStatus.done,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      position: 3000.0,
      assigneeId: 'orbit-crew-002',
      assigneeEmail: 'engineer@ai-orbit.space',
      source: 'manual',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      completedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  final StreamController<List<Task>> _mockStreamController =
      StreamController<List<Task>>.broadcast();

  TaskRepository(this._auth) {
    _mockStreamController.add(List<Task>.from(_mockTasks));
  }

  void _notifyMockStream() {
    _mockStreamController.add(List<Task>.from(_mockTasks));
  }

  Future<List<Task>> getTasks({String? workspaceId}) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      if (workspaceId != null) {
        return _mockTasks
            .where((t) => t.workspaceId == null || t.workspaceId == workspaceId)
            .toList();
      }
      return List<Task>.from(_mockTasks);
    }

    try {
      var query = _auth.client.from('tasks').select();
      if (workspaceId != null) {
        query = query.eq('workspace_id', workspaceId);
      }
      final response = await query.order('position', ascending: true);

      return (response as List<dynamic>)
          .map((row) => Task.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[TaskRepository] Error fetching tasks: $e');
      return List<Task>.from(_mockTasks);
    }
  }

  Stream<List<Task>> streamTasks({String? workspaceId}) {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      return _mockStreamController.stream;
    }

    try {
      final streamBuilder = _auth.client.from('tasks').stream(primaryKey: ['id']);
      final stream = workspaceId != null
          ? streamBuilder.eq('workspace_id', workspaceId)
          : streamBuilder;

      return stream.map((maps) {
        return maps.map((row) => Task.fromJson(row)).toList();
      });
    } catch (e) {
      debugPrint('[TaskRepository] Error establishing realtime stream: $e');
      return _mockStreamController.stream;
    }
  }

  Future<Task> createTask(Task task) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      final newTask = task.copyWith(
        id: 'task-${DateTime.now().microsecondsSinceEpoch}',
        creatorId: userId ?? 'orbit-local-user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockTasks.insert(0, newTask);
      _notifyMockStream();
      return newTask;
    }

    try {
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );
      final safeAssigneeId = (task.assigneeId != null && uuidRegex.hasMatch(task.assigneeId!))
          ? task.assigneeId
          : null;
      final safeSourceMessageId = (task.sourceMessageId != null && uuidRegex.hasMatch(task.sourceMessageId!))
          ? task.sourceMessageId
          : null;
      final safeSourceConversationId = (task.sourceConversationId != null && uuidRegex.hasMatch(task.sourceConversationId!))
          ? task.sourceConversationId
          : null;

      final payload = {
        if (task.workspaceId != null) 'workspace_id': task.workspaceId,
        'creator_id': userId,
        'title': task.title,
        'description': task.description,
        'priority': task.priority.toDbString(),
        'status': task.status.toDbString(),
        if (task.dueDate != null) 'due_date': task.dueDate!.toIso8601String(),
        'position': task.position,
        'assignee_id': ?safeAssigneeId,
        if (task.assignedAgentSlug != null)
          'assigned_agent_slug': task.assignedAgentSlug,
        'source': task.source,
        'source_conversation_id': ?safeSourceConversationId,
        'source_message_id': ?safeSourceMessageId,
      };

      final response =
          await _auth.client.from('tasks').insert(payload).select().single();

      return Task.fromJson(response);
    } catch (e) {
      debugPrint('[TaskRepository] Error creating task: $e');
      rethrow;
    }
  }

  Future<List<Task>> batchCreateTasks(List<Task> tasks) async {
    if (tasks.isEmpty) return [];
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      final createdList = <Task>[];
      for (final t in tasks) {
        final newTask = t.copyWith(
          id: 'task-${DateTime.now().microsecondsSinceEpoch}-${createdList.length}',
          creatorId: userId ?? 'orbit-local-user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _mockTasks.insert(0, newTask);
        createdList.add(newTask);
      }
      _notifyMockStream();
      return createdList;
    }

    try {
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );

      final payloads = tasks.map((task) {
        final safeAssigneeId = (task.assigneeId != null && uuidRegex.hasMatch(task.assigneeId!))
            ? task.assigneeId
            : null;
        final safeSourceMessageId = (task.sourceMessageId != null && uuidRegex.hasMatch(task.sourceMessageId!))
            ? task.sourceMessageId
            : null;
        final safeSourceConversationId = (task.sourceConversationId != null && uuidRegex.hasMatch(task.sourceConversationId!))
            ? task.sourceConversationId
            : null;

        return {
          if (task.workspaceId != null) 'workspace_id': task.workspaceId,
          'creator_id': userId,
          'title': task.title,
          'description': task.description,
          'priority': task.priority.toDbString(),
          'status': task.status.toDbString(),
          if (task.dueDate != null) 'due_date': task.dueDate!.toIso8601String(),
          'position': task.position,
          'assignee_id': ?safeAssigneeId,
          if (task.assignedAgentSlug != null)
            'assigned_agent_slug': task.assignedAgentSlug,
          'source': task.source,
          'source_conversation_id': ?safeSourceConversationId,
          'source_message_id': ?safeSourceMessageId,
        };
      }).toList();

      final response = await _auth.client.from('tasks').insert(payloads).select();
      final inserted = (response as List<dynamic>)
          .map((row) => Task.fromJson(row as Map<String, dynamic>))
          .toList();
      return inserted;
    } catch (e) {
      debugPrint('[TaskRepository] Error batch creating tasks: $e');
      rethrow;
    }
  }

  Future<Task> updateTask(Task task) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      final idx = _mockTasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        final updated = task.copyWith(
          updatedAt: DateTime.now(),
          completedAt: task.status == TaskStatus.done ? (task.completedAt ?? DateTime.now()) : null,
        );
        _mockTasks[idx] = updated;
        _notifyMockStream();
        return updated;
      }
      return task;
    }

    try {
      final payload = {
        'title': task.title,
        'description': task.description,
        'priority': task.priority.toDbString(),
        'status': task.status.toDbString(),
        'due_date': task.dueDate?.toIso8601String(),
        'position': task.position,
        'assignee_id': task.assigneeId,
        'assigned_agent_slug': task.assignedAgentSlug,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await _auth.client
          .from('tasks')
          .update(payload)
          .eq('id', task.id)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      debugPrint('[TaskRepository] Error updating task: $e');
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      final idx = _mockTasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        _mockTasks[idx] = _mockTasks[idx].copyWith(
          status: status,
          updatedAt: DateTime.now(),
          completedAt: status == TaskStatus.done ? DateTime.now() : null,
        );
        _notifyMockStream();
      }
      return;
    }

    try {
      await _auth.client.from('tasks').update({
        'status': status.toDbString(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', taskId);
    } catch (e) {
      debugPrint('[TaskRepository] Error updating task status: $e');
      rethrow;
    }
  }

  Future<void> updateTaskPosition(String taskId, double position) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      final idx = _mockTasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        _mockTasks[idx] = _mockTasks[idx].copyWith(position: position);
        _notifyMockStream();
      }
      return;
    }

    try {
      await _auth.client.from('tasks').update({
        'position': position,
      }).eq('id', taskId);
    } catch (e) {
      debugPrint('[TaskRepository] Error updating task position: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      _mockTasks.removeWhere((t) => t.id == taskId);
      _notifyMockStream();
      return;
    }

    try {
      await _auth.client.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      debugPrint('[TaskRepository] Error deleting task: $e');
      rethrow;
    }
  }

  /// Phase 4: Extract tasks from AI message using `ai-tasks` Edge Function
  Future<List<Map<String, dynamic>>> extractTasksFromMessage({
    required String messageId,
    String? workspaceId,
  }) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      return _offlineParseDrafts('Initialize Cybertron telemetry subsystem, review Earth roadmap specifications');
    }

    try {
      final response = await _auth.client.functions.invoke(
        'ai-tasks',
        body: {
          'mode': 'extract',
          'message_id': messageId,
          'workspace_id': ?workspaceId,
          'today_date': DateTime.now().toIso8601String().split('T')[0],
        },
      );

      final data = response.data;
      if (data != null && data['tasks'] is List) {
        return List<Map<String, dynamic>>.from(data['tasks']);
      }
      return [];
    } catch (e) {
      debugPrint('[TaskRepository] Error extracting tasks from edge function: $e');
      return [];
    }
  }

  /// Phase 4b: Natural-language Quick Add using `ai-tasks` Edge Function
  Future<List<Map<String, dynamic>>> parseTasksFromText({
    required String text,
    String? workspaceId,
  }) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      return _offlineParseDrafts(text);
    }

    try {
      final response = await _auth.client.functions.invoke(
        'ai-tasks',
        body: {
          'mode': 'parse',
          'text': text,
          'workspace_id': ?workspaceId,
          'today_date': DateTime.now().toIso8601String().split('T')[0],
          'timezone': DateTime.now().timeZoneName,
        },
      );

      final data = response.data;
      if (data != null && data['tasks'] is List && (data['tasks'] as List).isNotEmpty) {
        return List<Map<String, dynamic>>.from(data['tasks']);
      }
      return _offlineParseDrafts(text);
    } catch (e) {
      debugPrint('[TaskRepository] Error parsing text via edge function: $e');
      return _offlineParseDrafts(text);
    }
  }

  List<Map<String, dynamic>> _offlineParseDrafts(String prompt) {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return [];

    // Strip leading command prefixes like "Add task:", "Add tasks:", "Create tasks:", "/task"
    final text = trimmed.replaceFirst(
      RegExp(r'^(?:add|create|new)\s+(?:a\s+)?tasks?\s*(?:to\s*)?:?\s*', caseSensitive: false),
      '',
    ).trim();

    // Split multi-action sentences by comma, semicolon, newline, or "and"
    final rawClauses = text
        .split(RegExp(r'(?:,|;|\n|\band\b)', caseSensitive: false))
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    if (rawClauses.isEmpty) return [];

    final now = DateTime.now();
    final tasks = <_DraftTaskBuilder>[];

    final priorityPattern = RegExp(
      r'^\s*(urgent|asap|critical|high(?:\s+priority)?|medium(?:\s+priority)?|low(?:\s+priority)?)\s*$',
      caseSensitive: false,
    );

    final assigneePattern = RegExp(
      r'^\s*(?:assign(?:ed)?\s+(?:it\s+)?to|give\s+(?:it\s+)?to|with|for|assignee:?)\s+([a-zA-Z0-9_\-\.\@\s]+)$',
      caseSensitive: false,
    );

    final temporalOnlyPattern = RegExp(
      r'^\s*(?:by|due|on)?\s*(today|tomorrow|monday|tuesday|wednesday|thursday|friday|saturday|sunday|next\s+week|this\s+week|by\s+tonight|by\s+eod)\s*$',
      caseSensitive: false,
    );

    for (final clause in rawClauses) {
      final lower = clause.toLowerCase();

      // 1. Check if this clause is purely a priority modifier
      final priorityMatch = priorityPattern.firstMatch(clause);
      if (priorityMatch != null) {
        final pStr = priorityMatch.group(1)!.toLowerCase();
        final p = (pStr.contains('urgent') || pStr.contains('asap') || pStr.contains('critical'))
            ? TaskPriority.urgent
            : (pStr.contains('high'))
                ? TaskPriority.high
                : (pStr.contains('low'))
                    ? TaskPriority.low
                    : TaskPriority.medium;

        if (tasks.isNotEmpty) {
          tasks.last.priority = p;
        } else {
          tasks.add(_DraftTaskBuilder(priority: p));
        }
        continue;
      }

      // 2. Check if this clause is purely an assignee modifier
      final assigneeMatch = assigneePattern.firstMatch(clause);
      if (assigneeMatch != null) {
        final target = assigneeMatch.group(1)!.toLowerCase().trim();
        final matchedPlanet = Planet.findBySlugOrName(target);
        if (tasks.isNotEmpty) {
          if (matchedPlanet != null) {
            tasks.last.planetSlug = matchedPlanet.slug;
            tasks.last.planetLabel = matchedPlanet.name;
          } else {
            tasks.last.assigneeLabel = target;
          }
        } else {
          final builder = _DraftTaskBuilder();
          if (matchedPlanet != null) {
            builder.planetSlug = matchedPlanet.slug;
            builder.planetLabel = matchedPlanet.name;
          } else {
            builder.assigneeLabel = target;
          }
          tasks.add(builder);
        }
        continue;
      }

      // 3. Check if this clause is purely a due date modifier
      final temporalMatch = temporalOnlyPattern.firstMatch(clause);
      if (temporalMatch != null) {
        final d = _extractDueDate(temporalMatch.group(1)!.toLowerCase(), now);
        if (tasks.isNotEmpty) {
          tasks.last.dueDate = d;
        } else {
          tasks.add(_DraftTaskBuilder(dueDate: d));
        }
        continue;
      }

      // 4. Otherwise, this clause contains an actual task action or title
      final builder = _DraftTaskBuilder(title: clause);

      // Extract inline priority if mentioned
      if (lower.contains('urgent') || lower.contains('asap') || lower.contains('critical')) {
        builder.priority = TaskPriority.urgent;
      } else if (lower.contains('high priority') || lower.contains('important')) {
        builder.priority = TaskPriority.high;
      } else if (lower.contains('low priority') || lower.contains('minor')) {
        builder.priority = TaskPriority.low;
      }

      // Extract inline due date if mentioned
      builder.dueDate = _extractDueDate(lower, now);

      // Extract inline planet if mentioned
      for (final p in ['mars', 'saturn', 'earth', 'jupiter', 'neptune', 'pluto']) {
        if (RegExp('\\b$p\\b', caseSensitive: false).hasMatch(lower)) {
          final matchedPlanet = Planet.findBySlugOrName(p);
          if (matchedPlanet != null) {
            builder.planetSlug = matchedPlanet.slug;
            builder.planetLabel = matchedPlanet.name;
            break;
          }
        }
      }

      // Clean the title: remove inline dates, assign phrases, and priority tags
      var cleanTitle = clause;
      cleanTitle = cleanTitle.replaceAll(
        RegExp(r'\b(today|tomorrow|by\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)|next\s+week|this\s+week|by\s+tonight|by\s+eod)\b', caseSensitive: false),
        '',
      );
      cleanTitle = cleanTitle.replaceAll(
        RegExp(r'\b(?:with|give\s+(?:it\s+)?to|assign(?:ed)?\s+(?:it\s+)?to)\s+(?:saturn|mars|earth|jupiter|neptune|pluto)\b', caseSensitive: false),
        '',
      );
      cleanTitle = cleanTitle.replaceAll(
        RegExp(r'\b(urgent|asap|critical|high\s+priority|low\s+priority)\b', caseSensitive: false),
        '',
      );
      cleanTitle = cleanTitle.replaceAll(RegExp(r'\s{2,}'), ' ').trim();

      if (cleanTitle.isNotEmpty) {
        cleanTitle = cleanTitle[0].toUpperCase() + cleanTitle.substring(1);
      }
      builder.title = cleanTitle.isEmpty ? clause : cleanTitle;
      builder.originalClause = clause;

      // If previous task had no title (e.g. priority modifier came first), merge with it
      if (tasks.isNotEmpty && (tasks.last.title == null || tasks.last.title!.isEmpty)) {
        tasks.last.title = builder.title;
        tasks.last.originalClause = builder.originalClause;
        if (builder.dueDate != null) tasks.last.dueDate = builder.dueDate;
        if (builder.planetSlug != null) {
          tasks.last.planetSlug = builder.planetSlug;
          tasks.last.planetLabel = builder.planetLabel;
        }
      } else {
        tasks.add(builder);
      }

      if (tasks.length >= 8) break;
    }

    return tasks.map((b) => b.toMap()).toList();
  }

  static DateTime? _extractDueDate(String text, DateTime now) {
    final lower = text.toLowerCase();
    if (lower.contains('today')) {
      return DateTime(now.year, now.month, now.day, 23, 59);
    } else if (lower.contains('tomorrow')) {
      return now.add(const Duration(days: 1));
    } else if (lower.contains('monday')) {
      final daysUntilMonday = ((8 - now.weekday) % 7 == 0) ? 7 : (8 - now.weekday) % 7;
      return now.add(Duration(days: daysUntilMonday));
    } else if (lower.contains('tuesday')) {
      final days = ((2 - now.weekday) + 7) % 7;
      return now.add(Duration(days: days == 0 ? 7 : days));
    } else if (lower.contains('wednesday')) {
      final days = ((3 - now.weekday) + 7) % 7;
      return now.add(Duration(days: days == 0 ? 7 : days));
    } else if (lower.contains('thursday')) {
      final days = ((4 - now.weekday) + 7) % 7;
      return now.add(Duration(days: days == 0 ? 7 : days));
    } else if (lower.contains('friday')) {
      final daysUntilFriday = ((5 - now.weekday) + 7) % 7;
      return now.add(Duration(days: daysUntilFriday == 0 ? 7 : daysUntilFriday));
    } else if (lower.contains('saturday')) {
      final days = ((6 - now.weekday) + 7) % 7;
      return now.add(Duration(days: days == 0 ? 7 : days));
    } else if (lower.contains('sunday')) {
      final days = ((7 - now.weekday) + 7) % 7;
      return now.add(Duration(days: days == 0 ? 7 : days));
    }
    return null;
  }
}

class _DraftTaskBuilder {
  String? title;
  String originalClause = '';
  TaskPriority priority;
  DateTime? dueDate;
  String? planetSlug;
  String? planetLabel;
  String? assigneeLabel;

  _DraftTaskBuilder({
    this.title,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': (title != null && title!.isNotEmpty) ? title! : 'New orbital task',
      'description': 'Parsed from input transmission: "${originalClause.isEmpty ? (title ?? '') : originalClause}"',
      'priority': priority.toDbString(),
      'due_date': dueDate?.toIso8601String(),
      'assigned_agent_slug': planetSlug,
      'assignee_label': planetLabel ?? assigneeLabel,
      'assignee_id': null,
    };
  }
}
