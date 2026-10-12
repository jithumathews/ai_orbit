import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/workspace_repository.dart';
import '../domain/models/workspace.dart';
import '../domain/models/workspace_member.dart';

class WorkspaceState {
  final List<Workspace> workspaces;
  final Workspace? activeWorkspace;
  final List<WorkspaceMember> members;
  final bool isLoading;
  final String? errorMessage;

  const WorkspaceState({
    this.workspaces = const [],
    this.activeWorkspace,
    this.members = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  WorkspaceState copyWith({
    List<Workspace>? workspaces,
    Workspace? activeWorkspace,
    List<WorkspaceMember>? members,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      activeWorkspace: activeWorkspace ?? this.activeWorkspace,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final workspaceNotifierProvider =
    StateNotifierProvider<WorkspaceNotifier, WorkspaceState>((ref) {
  final repo = ref.watch(workspaceRepositoryProvider);
  return WorkspaceNotifier(repo);
});

class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  final WorkspaceRepository _repo;

  WorkspaceNotifier(this._repo) : super(const WorkspaceState()) {
    bootstrap();
  }

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getWorkspaces();
      if (!mounted) return;
      Workspace? active = state.activeWorkspace;
      if (active == null && list.isNotEmpty) {
        active = list.first;
      }
      List<WorkspaceMember> members = [];
      if (active != null) {
        members = await _repo.getWorkspaceMembers(active.id);
        if (!mounted) return;
      }
      state = state.copyWith(
        workspaces: list,
        activeWorkspace: active,
        members: members,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectWorkspace(Workspace workspace) async {
    state = state.copyWith(activeWorkspace: workspace, isLoading: true);
    try {
      final members = await _repo.getWorkspaceMembers(workspace.id);
      if (!mounted) return;
      state = state.copyWith(members: members, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<Workspace?> createWorkspace(String name, String slug) async {
    try {
      final ws = await _repo.createWorkspace(name: name, slug: slug);
      final updatedList = [...state.workspaces, ws];
      final members = await _repo.getWorkspaceMembers(ws.id);
      state = state.copyWith(
        workspaces: updatedList,
        activeWorkspace: ws,
        members: members,
      );
      return ws;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> inviteMember(String email, {String role = 'member'}) async {
    if (state.activeWorkspace == null) return false;
    try {
      final success = await _repo.inviteMember(
        workspaceId: state.activeWorkspace!.id,
        email: email,
        role: role,
      );
      if (success) {
        final members = await _repo.getWorkspaceMembers(state.activeWorkspace!.id);
        state = state.copyWith(members: members);
      }
      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
