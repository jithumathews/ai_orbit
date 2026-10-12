import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_orbit/features/auth/data/auth_repository.dart';
import 'package:ai_orbit/features/tasks/data/task_repository.dart';
import 'package:ai_orbit/features/tasks/domain/models/task.dart';
import 'package:ai_orbit/features/tasks/domain/models/task_priority.dart';
import 'package:ai_orbit/features/tasks/domain/models/task_status.dart';
import 'package:ai_orbit/features/tasks/presentation/task_notifier.dart';
import 'package:ai_orbit/features/tasks/presentation/workspace_notifier.dart';
import 'package:ai_orbit/features/tasks/presentation/widgets/task_badge.dart';
import 'package:ai_orbit/features/tasks/presentation/widgets/task_suggestions_card.dart';

void main() {
  group('Task Management - Domain & Enums', () {
    test('TaskPriority weights and labels are ordered correctly', () {
      expect(TaskPriority.urgent.weight, greaterThan(TaskPriority.high.weight));
      expect(TaskPriority.high.weight, greaterThan(TaskPriority.medium.weight));
      expect(TaskPriority.medium.weight, greaterThan(TaskPriority.low.weight));

      expect(TaskPriority.fromString('asap'), TaskPriority.urgent);
      expect(TaskPriority.fromString('critical'), TaskPriority.urgent);
      expect(TaskPriority.fromString('high'), TaskPriority.high);
      expect(TaskPriority.fromString('low'), TaskPriority.low);
      expect(TaskPriority.fromString('unknown'), TaskPriority.medium);
    });

    test('TaskStatus transitions and completed_at flags', () {
      final now = DateTime.now();
      final task = Task(
        id: 't-1',
        creatorId: 'u-1',
        title: 'Calibrate propulsion sensors',
        priority: TaskPriority.urgent,
        status: TaskStatus.todo,
        createdAt: now,
        updatedAt: now,
      );

      expect(task.isCompleted, isFalse);

      final doneTask = task.copyWith(
        status: TaskStatus.done,
        completedAt: now,
      );
      expect(doneTask.isCompleted, isTrue);
    });

    test('Task due date indicators (overdue, due today, due soon)', () {
      final now = DateTime.now();

      final overdueTask = Task(
        id: 't-overdue',
        creatorId: 'u-1',
        title: 'Overdue task',
        dueDate: now.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      );
      expect(overdueTask.isOverdue, isTrue);

      final todayTask = Task(
        id: 't-today',
        creatorId: 'u-1',
        title: 'Today task',
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );
      expect(todayTask.isDueToday, isTrue);

      final soonTask = Task(
        id: 't-soon',
        creatorId: 'u-1',
        title: 'Soon task',
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      );
      expect(soonTask.isDueSoon, isTrue);
    });
  });

  group('TaskNotifier - CRUD and Sorting', () {
    late ProviderContainer container;
    late AuthRepository authRepo;

    setUp(() async {
      authRepo = AuthRepository();
      authRepo.enterDemoPass();

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      await container.read(workspaceNotifierProvider.notifier).bootstrap();
      container.listen(taskNotifierProvider, (prev, next) {});
    });

    tearDown(() {
      container.dispose();
    });

    test('Loads initial tasks and reports open count accurately', () async {
      final notifier = container.read(taskNotifierProvider.notifier);
      await notifier.bootstrap();

      final state = container.read(taskNotifierProvider);
      expect(state.tasks.isNotEmpty, isTrue);
      expect(state.openTaskCount, greaterThan(0));
    });

    test('Creates, updates status, and deletes tasks cleanly', () async {
      final notifier = container.read(taskNotifierProvider.notifier);
      await notifier.bootstrap();

      // Create Task
      final created = await notifier.createTask(
        title: 'Test Cybertron Protocol',
        description: 'Verify Mars coding agent subsystem',
        priority: TaskPriority.urgent,
        assignedAgentSlug: 'mars',
      );

      expect(created, isNotNull);
      expect(created!.title, 'Test Cybertron Protocol');
      expect(created.priority, TaskPriority.urgent);
      expect(created.assignedAgentSlug, 'mars');

      // Update Status to Done
      await notifier.updateStatus(created.id, TaskStatus.done);
      final updatedTask = container
          .read(taskNotifierProvider)
          .tasks
          .firstWhere((t) => t.id == created.id);
      expect(updatedTask.status, TaskStatus.done);
      expect(updatedTask.completedAt, isNotNull);

      // Delete Task
      final deleted = await notifier.deleteTask(created.id);
      expect(deleted, isTrue);
      expect(
        container
            .read(taskNotifierProvider)
            .tasks
            .any((t) => t.id == created.id),
        isFalse,
      );
    });

    test('Tasks are sorted by priority (urgent > high > medium > low), then due date', () async {
      final notifier = container.read(taskNotifierProvider.notifier);
      await notifier.bootstrap();

      // Add low, high, urgent tasks
      await notifier.createTask(title: 'Low Prio', priority: TaskPriority.low);
      await notifier.createTask(title: 'Urgent Prio', priority: TaskPriority.urgent);
      await notifier.createTask(title: 'High Prio', priority: TaskPriority.high);

      final state = container.read(taskNotifierProvider);
      final todoTasks = state.tasksForStatus(TaskStatus.todo);

      // Verify urgent comes before high, and high before low
      final urgentIdx = todoTasks.indexWhere((t) => t.title == 'Urgent Prio');
      final highIdx = todoTasks.indexWhere((t) => t.title == 'High Prio');
      final lowIdx = todoTasks.indexWhere((t) => t.title == 'Low Prio');

      expect(urgentIdx, lessThan(highIdx));
      expect(highIdx, lessThan(lowIdx));
    });

    test('Filter by planet and assignee works as expected', () async {
      final notifier = container.read(taskNotifierProvider.notifier);
      await notifier.bootstrap();

      notifier.setPlanetFilter('mars');
      var state = container.read(taskNotifierProvider);
      for (final t in state.filteredTasks) {
        expect(t.assignedAgentSlug, 'mars');
      }

      notifier.setPlanetFilter(null);
      notifier.setPriorityFilter(TaskPriority.urgent);
      state = container.read(taskNotifierProvider);
      for (final t in state.filteredTasks) {
        expect(t.priority, TaskPriority.urgent);
      }
    });
  });

  group('Task Extraction & Batch Creation', () {
    test('parseTasksFromText extracts multi-clause command with Saturn and relative dates', () async {
      final authRepo = AuthRepository()..enterDemoPass();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(authRepo)],
      );
      await container.read(workspaceNotifierProvider.notifier).bootstrap();
      final taskRepo = container.read(taskRepositoryProvider);

      const prompt = 'Deploy the new migrations today, test the RLS policies with Saturn by tomorrow, and write release notes by Monday';
      final drafts = await taskRepo.parseTasksFromText(text: prompt);

      expect(drafts.length, 3);
      expect(drafts[0]['title'].toString().toLowerCase(), contains('deploy the new migrations'));
      expect(drafts[1]['title'].toString().toLowerCase(), contains('test the rls policies'));
      expect(drafts[1]['assigned_agent_slug'], 'reasoning');
      expect(drafts[1]['assignee_label'], 'Saturn');
      expect(drafts[2]['title'].toString().toLowerCase(), contains('write release notes'));

      // Test batch creation of these tasks
      final notifier = container.read(taskNotifierProvider.notifier);
      final tasksToCreate = drafts.map((d) => Task(
        id: '',
        creatorId: 'orbit-demo-user',
        title: d['title'] as String,
        description: d['description'] as String,
        priority: TaskPriority.fromString(d['priority'] as String),
        assignedAgentSlug: d['assigned_agent_slug'] as String?,
        dueDate: d['due_date'] != null ? DateTime.parse(d['due_date'] as String) : null,
        source: 'ai',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();

      final created = await notifier.createTasksBatch(tasksToCreate);
      expect(created.length, 3);
      expect(container.read(taskNotifierProvider).tasks.length, greaterThanOrEqualTo(3));

      container.dispose();
    });

    test('parseTasksFromText combines single task attributes instead of making multiple tasks', () async {
      final authRepo = AuthRepository()..enterDemoPass();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(authRepo)],
      );
      await container.read(workspaceNotifierProvider.notifier).bootstrap();
      final taskRepo = container.read(taskRepositoryProvider);

      const prompt = 'Add tasks: Fix quota RPC by Friday, urgent, assign to Mars';
      final drafts = await taskRepo.parseTasksFromText(text: prompt);

      expect(drafts.length, 1);
      final task = drafts.first;
      expect(task['title'].toString().toLowerCase(), contains('fix quota rpc'));
      expect(task['priority'], 'urgent');
      expect(task['assigned_agent_slug'], 'coding');
      expect(task['assignee_label'], 'Mars');
      expect(task['due_date'], isNotNull);

      container.dispose();
    });
  });

  group('WorkspaceNotifier - Collaboration and Members', () {
    test('Loads workspace and handles member invites', () async {
      final authRepo = AuthRepository()..enterDemoPass();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );

      final wsNotifier = container.read(workspaceNotifierProvider.notifier);
      await wsNotifier.bootstrap();

      final wsState = container.read(workspaceNotifierProvider);
      expect(wsState.workspaces.isNotEmpty, isTrue);
      expect(wsState.members.isNotEmpty, isTrue);

      // Invite member
      final ok = await wsNotifier.inviteMember('navigator@ai-orbit.space');
      expect(ok, isTrue);

      final updatedState = container.read(workspaceNotifierProvider);
      expect(
        updatedState.members.any((m) => m.email == 'navigator@ai-orbit.space'),
        isTrue,
      );

      container.dispose();
    });
  });

  group('Widgets - TaskCard, Badges & Suggestions Card', () {
    testWidgets('PriorityBadge and StatusBadge render correct colors',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PriorityBadge(priority: TaskPriority.urgent),
                StatusBadge(status: TaskStatus.inProgress),
              ],
            ),
          ),
        ),
      );

      expect(find.text('URGENT'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('TaskSuggestionsCard allows editing and confirms creation',
        (tester) async {
      int created = 0;
      bool dismissed = false;

      final testDrafts = [
        {
          'title': 'Implement RLS policy audit script',
          'description': 'Ensure two-user isolation',
          'priority': 'urgent',
          'assigned_agent_slug': 'mars',
          'assignee_label': 'MARS',
        },
        {
          'title': 'Draft constellation roadmap',
          'description': 'Phase 4 execution checkpoints',
          'priority': 'high',
          'assigned_agent_slug': 'earth',
          'assignee_label': 'EARTH',
        },
      ];

      final authRepo = AuthRepository()..enterDemoPass();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: TaskSuggestionsCard(
                rawDrafts: testDrafts,
                sourceMessageId: 'msg-test-123',
                onDismiss: () => dismissed = true,
                onCreated: (count) => created = count,
              ),
            ),
          ),
        ),
      );

      // Suggestions card rendered
      expect(find.text('PROPOSED ORBITAL TASKS (CONFIRMATION)'), findsOneWidget);
      expect(find.text('Confirm & Create (2)'), findsOneWidget);

      // Tap Confirm & Create
      await tester.tap(find.text('Confirm & Create (2)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(created, 2);
      expect(dismissed, isFalse);

      container.dispose();
    });
  });
}
