import 'package:flutter/material.dart';

enum TaskStatus {
  todo,
  inProgress,
  blocked,
  done;

  String get label => switch (this) {
    TaskStatus.todo => 'To Do',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.blocked => 'Blocked',
    TaskStatus.done => 'Done',
  };

  IconData get icon => switch (this) {
    TaskStatus.todo => Icons.radio_button_unchecked,
    TaskStatus.inProgress => Icons.hourglass_top_rounded,
    TaskStatus.blocked => Icons.block_flipped,
    TaskStatus.done => Icons.check_circle_rounded,
  };

  Color get color => switch (this) {
    TaskStatus.todo => const Color(0xFF7C4DFF),       // Cosmic Purple
    TaskStatus.inProgress => const Color(0xFF00E5FF), // Earth Cyan
    TaskStatus.blocked => const Color(0xFFFF5252),    // Mars Crimson
    TaskStatus.done => const Color(0xFF00E676),       // Neptune Emerald
  };

  static TaskStatus fromString(String? value) {
    return switch (value?.toLowerCase().trim()) {
      'in_progress' || 'inprogress' => TaskStatus.inProgress,
      'blocked' => TaskStatus.blocked,
      'done' || 'completed' => TaskStatus.done,
      _ => TaskStatus.todo,
    };
  }

  String toDbString() => switch (this) {
    TaskStatus.todo => 'todo',
    TaskStatus.inProgress => 'in_progress',
    TaskStatus.blocked => 'blocked',
    TaskStatus.done => 'done',
  };
}
