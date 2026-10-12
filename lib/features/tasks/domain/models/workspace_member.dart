class WorkspaceMember {
  final String id;
  final String workspaceId;
  final String userId;
  final String email;
  final String role; // 'owner' | 'admin' | 'member'
  final DateTime joinedAt;

  const WorkspaceMember({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin' || role == 'owner';

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      id: json['member_id'] as String? ?? json['id'] as String? ?? '',
      workspaceId: json['workspace_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? 'explorer@ai-orbit.space',
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspace_id': workspaceId,
      'user_id': userId,
      'email': email,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
