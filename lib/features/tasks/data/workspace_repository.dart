import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/models/workspace.dart';
import '../domain/models/workspace_member.dart';

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return WorkspaceRepository(authRepo);
});

class WorkspaceRepository {
  final AuthRepository _auth;

  final List<Workspace> _mockWorkspaces = [
    Workspace(
      id: 'ws-demo-constellation',
      name: 'Constellation Core',
      slug: 'constellation-core',
      ownerId: 'orbit-explorer-001',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
  ];

  final Map<String, List<WorkspaceMember>> _mockMembers = {
    'ws-demo-constellation': [
      WorkspaceMember(
        id: 'mem-1',
        workspaceId: 'ws-demo-constellation',
        userId: 'orbit-explorer-001',
        email: 'explorer@ai-orbit.space',
        role: 'owner',
        joinedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      WorkspaceMember(
        id: 'mem-2',
        workspaceId: 'ws-demo-constellation',
        userId: 'orbit-crew-002',
        email: 'engineer@ai-orbit.space',
        role: 'member',
        joinedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ],
  };

  WorkspaceRepository(this._auth);

  Future<List<Workspace>> getWorkspaces() async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      return List<Workspace>.from(_mockWorkspaces);
    }

    try {
      final response = await _auth.client
          .from('workspaces')
          .select()
          .order('created_at', ascending: true);

      final list = (response as List<dynamic>)
          .map((row) => Workspace.fromJson(row as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) {
        // Auto-create initial personal workspace if user has none
        final initial = await createWorkspace(
          name: 'Personal Orbit',
          slug: 'orbit-${userId.substring(0, 8)}',
        );
        return [initial];
      }

      return list;
    } catch (e) {
      debugPrint('[WorkspaceRepository] Error fetching workspaces: $e');
      return List<Workspace>.from(_mockWorkspaces);
    }
  }

  Future<Workspace> createWorkspace({
    required String name,
    required String slug,
  }) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      final ws = Workspace(
        id: 'ws-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        slug: slug,
        ownerId: userId ?? 'orbit-local-user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockWorkspaces.add(ws);
      _mockMembers[ws.id] = [
        WorkspaceMember(
          id: 'mem-${DateTime.now().millisecondsSinceEpoch}',
          workspaceId: ws.id,
          userId: ws.ownerId,
          email: _auth.currentEmail ?? 'explorer@ai-orbit.space',
          role: 'owner',
          joinedAt: DateTime.now(),
        ),
      ];
      return ws;
    }

    try {
      final response = await _auth.client
          .from('workspaces')
          .insert({
            'name': name,
            'slug': slug,
            'owner_id': userId,
          })
          .select()
          .single();

      return Workspace.fromJson(response);
    } catch (e) {
      debugPrint('[WorkspaceRepository] Error creating workspace: $e');
      rethrow;
    }
  }

  Future<List<WorkspaceMember>> getWorkspaceMembers(String workspaceId) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      return List<WorkspaceMember>.from(_mockMembers[workspaceId] ?? []);
    }

    try {
      final response = await _auth.client.rpc('get_workspace_members', params: {
        'p_workspace_id': workspaceId,
      });

      return (response as List<dynamic>)
          .map((row) => WorkspaceMember.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[WorkspaceRepository] Error fetching workspace members: $e');
      return List<WorkspaceMember>.from(_mockMembers[workspaceId] ?? []);
    }
  }

  Future<bool> inviteMember({
    required String workspaceId,
    required String email,
    String role = 'member',
  }) async {
    final userId = _auth.currentUserId;
    if (_auth.isMockMode || userId == null || userId.startsWith('orbit-')) {
      final member = WorkspaceMember(
        id: 'mem-${DateTime.now().millisecondsSinceEpoch}',
        workspaceId: workspaceId,
        userId: 'orbit-invited-${email.hashCode}',
        email: email,
        role: role,
        joinedAt: DateTime.now(),
      );
      _mockMembers.putIfAbsent(workspaceId, () => []).add(member);
      return true;
    }

    try {
      final response = await _auth.client.rpc('invite_workspace_member', params: {
        'p_workspace_id': workspaceId,
        'p_email': email.trim().toLowerCase(),
        'p_role': role,
      });

      return (response as Map<String, dynamic>)['success'] == true;
    } catch (e) {
      debugPrint('[WorkspaceRepository] Error inviting member: $e');
      return false;
    }
  }
}
