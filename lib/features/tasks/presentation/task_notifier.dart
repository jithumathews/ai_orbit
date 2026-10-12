import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../data/task_repository.dart';
import '../domain/models/task.dart';
import '../domain/models/task_priority.dart';
import '../domain/models/task_status.dart';
import 'workspace_notifier.dart';

enum TaskViewMode {
  list,
  kanban,
}

class TaskState {
  final List<Task> tasks;
  final bool isLoading;
  final String? filterAssignee; // null = all, 'me', 'unassigned', 'agent:<slug>', 'user:<id>'
  final TaskPriority? filterPriority;
  final String? filterPlanet; // null = all, or slug like 'mars', 'earth'
  final String searchQuery;
  final TaskViewMode viewMode;
  final String? errorMessage;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.filterAssignee,
    this.filterPriority,
    this.filterPlanet,
    this.searchQuery = '',
    this.viewMode = TaskViewMode.list,
    this.errorMessage,
  });

  int get openTaskCount =>
      tasks.where((t) => t.status != TaskStatus.done).length;

  int get urgentCount =>
      tasks.where((t) => t.priority == TaskPriority.urgent && t.status != TaskStatus.done).length;

  List<Task> get filteredTasks {
    return tasks.where((task) {
      // Search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(q);
        final matchesDesc = task.description.toLowerCase().contains(q);
        if (!matchesTitle && !matchesDesc) return false;
      }

      // Priority filter
      if (filterPriority != null && task.priority != filterPriority) {
        return false;
      }

      // Planet filter
      if (filterPlanet != null && task.assignedAgentSlug != filterPlanet) {
        return false;
      }

      // Assignee filter
      if (filterAssignee != null) {
        if (filterAssignee == 'unassigned') {
          if (task.assigneeId != null || task.assignedAgentSlug != null) return false;
        } else if (filterAssignee == 'me') {
          // Handled inside notifier helper or check ID
        } else if (filterAssignee!.startsWith('agent:')) {
          final slug = filterAssignee!.replaceFirst('agent:', '');
          if (task.assignedAgentSlug != slug) return false;
        } else if (filterAssignee!.startsWith('user:')) {
          final uid = filterAssignee!.replaceFirst('user:', '');
          if (task.assigneeId != uid) return false;
        }
      }

      return true;
    }).toList();
  }

  List<Task> tasksForStatus(TaskStatus status, {String? currentUserId}) {
    final list = filteredTasks.where((t) {
      if (t.status != status) return false;
      if (filterAssignee == 'me') {
        if (currentUserId == null || (t.assigneeId != currentUserId && t.creatorId != currentUserId)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sort by priority (urgent > high > medium > low), then due date ASC, then position
    list.sort((a, b) {
      final prioComp = b.priority.weight.compareTo(a.priority.weight);
      if (prioComp != 0) return prioComp;

      if (a.dueDate != null && b.dueDate != null) {
        final dateComp = a.dueDate!.compareTo(b.dueDate!);
        if (dateComp != 0) return dateComp;
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      return a.position.compareTo(b.position);
    });

    return list;
  }

  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? filterAssignee,
    bool clearFilterAssignee = false,
    TaskPriority? filterPriority,
    bool clearFilterPriority = false,
    String? filterPlanet,
    bool clearFilterPlanet = false,
    String? searchQuery,
    TaskViewMode? viewMode,
    String? errorMessage,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      filterAssignee: clearFilterAssignee ? null : (filterAssignee ?? this.filterAssignee),
      filterPriority: clearFilterPriority ? null : (filterPriority ?? this.filterPriority),
      filterPlanet: clearFilterPlanet ? null : (filterPlanet ?? this.filterPlanet),
      searchQuery: searchQuery ?? this.searchQuery,
      viewMode: viewMode ?? this.viewMode,
      errorMessage: errorMessage,
    );
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final auth = ref.watch(authRepositoryProvider);
  final initialWsId =
      ref.read(workspaceNotifierProvider).activeWorkspace?.id;
  final notifier = TaskNotifier(repo, auth, initialWsId);

  ref.listen<String?>(
    workspaceNotifierProvider.select((ws) => ws.activeWorkspace?.id),
    (previous, next) {
      if (previous != next) {
        notifier.switchWorkspace(next);
      }
    },
  );

  return notifier;
});

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repo;
  final AuthRepository _auth;
  String? _workspaceId;
  StreamSubscription<List<Task>>? _streamSub;

  TaskNotifier(this._repo, this._auth, this._workspaceId)
      : super(const TaskState());

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  String? get currentUserId => _auth.currentUserId;
  String? get workspaceId => _workspaceId;

  Future<void> switchWorkspace(String? newWorkspaceId) async {
    if (_workspaceId == newWorkspaceId) return;
    _workspaceId = newWorkspaceId;
    await bootstrap();
  }

  Future<void> bootstrap() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getTasks(workspaceId: _workspaceId);
      if (!mounted) return;
      state = state.copyWith(tasks: list, isLoading: false);

      // Listen to realtime updates
      _streamSub?.cancel();
      _streamSub = _repo.streamTasks(workspaceId: _workspaceId).listen(
        (updatedTasks) {
          if (mounted) {
            state = state.copyWith(tasks: updatedTasks);
          }
        },
        onError: (err) {
          debugPrint('[TaskNotifier] Stream error: $err');
        },
      );
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  void setAssigneeFilter(String? filter) {
    if (filter == null) {
      state = state.copyWith(clearFilterAssignee: true);
    } else {
      state = state.copyWith(filterAssignee: filter);
    }
  }

  void setPriorityFilter(TaskPriority? priority) {
    if (priority == null) {
      state = state.copyWith(clearFilterPriority: true);
    } else {
      state = state.copyWith(filterPriority: priority);
    }
  }

  void setPlanetFilter(String? planetSlug) {
    if (planetSlug == null) {
      state = state.copyWith(clearFilterPlanet: true);
    } else {
      state = state.copyWith(filterPlanet: planetSlug);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == TaskViewMode.list
          ? TaskViewMode.kanban
          : TaskViewMode.list,
    );
  }

  void setViewMode(TaskViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  Future<Task?> createTask({
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    TaskStatus status = TaskStatus.todo,
    DateTime? dueDate,
    String? assigneeId,
    String? assignedAgentSlug,
    String source = 'manual',
    String? sourceConversationId,
    String? sourceMessageId,
  }) async {
    try {
      // Calculate next position
      final maxPos = state.tasks.isEmpty
          ? 0.0
          : state.tasks.map((t) => t.position).reduce((a, b) => a > b ? a : b);

      final task = Task(
        id: '',
        workspaceId: _workspaceId,
        creatorId: _auth.currentUserId ?? 'orbit-user',
        title: title,
        description: description,
        priority: priority,
        status: status,
        dueDate: dueDate,
        position: maxPos + 1000.0,
        assigneeId: assigneeId,
        assignedAgentSlug: assignedAgentSlug,
        source: source,
        sourceConversationId: sourceConversationId,
        sourceMessageId: sourceMessageId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _repo.createTask(task);
      if (!mounted) return created;
      final exists = state.tasks.any((t) => t.id == created.id);
      if (!exists) {
        state = state.copyWith(tasks: [created, ...state.tasks]);
      }
      return created;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
      return null;
    }
  }

  Future<List<Task>> createTasksBatch(List<Task> tasks) async {
    if (tasks.isEmpty) return [];
    try {
      var basePos = state.tasks.isEmpty
          ? 0.0
          : state.tasks.map((t) => t.position).reduce((a, b) => a > b ? a : b);

      final preparedTasks = tasks.map((t) {
        basePos += 1000.0;
        return t.copyWith(
          workspaceId: t.workspaceId ?? _workspaceId,
          creatorId: t.creatorId.isEmpty ? (_auth.currentUserId ?? 'orbit-user') : t.creatorId,
          position: t.position > 0 ? t.position : basePos,
        );
      }).toList();

      final inserted = await _repo.batchCreateTasks(preparedTasks);
      if (!mounted) return inserted;

      final existingIds = state.tasks.map((t) => t.id).toSet();
      final newItems = inserted.where((t) => !existingIds.contains(t.id)).toList();
      state = state.copyWith(tasks: [...newItems, ...state.tasks]);
      return inserted;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
      rethrow;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      final updated = await _repo.updateTask(task);
      if (!mounted) return true;
      final list = state.tasks.map((t) => t.id == updated.id ? updated : t).toList();
      state = state.copyWith(tasks: list);
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
      return false;
    }
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    try {
      await _repo.updateTaskStatus(taskId, status);
      if (!mounted) return;
      final list = state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(
            status: status,
            updatedAt: DateTime.now(),
            completedAt: status == TaskStatus.done ? DateTime.now() : null,
          );
        }
        return t;
      }).toList();
      state = state.copyWith(tasks: list);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
    }
  }

  Future<void> reorderTask({
    required String taskId,
    required TaskStatus newStatus,
    required double newPosition,
  }) async {
    try {
      await _repo.updateTaskStatus(taskId, newStatus);
      await _repo.updateTaskPosition(taskId, newPosition);
      if (!mounted) return;

      final list = state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(
            status: newStatus,
            position: newPosition,
            updatedAt: DateTime.now(),
            completedAt: newStatus == TaskStatus.done ? DateTime.now() : null,
          );
        }
        return t;
      }).toList();
      state = state.copyWith(tasks: list);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _repo.deleteTask(taskId);
      if (!mounted) return true;
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != taskId).toList(),
      );
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
      return false;
    }
  }
}
