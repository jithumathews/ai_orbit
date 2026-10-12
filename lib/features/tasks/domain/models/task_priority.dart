import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
    TaskPriority.urgent => 'Urgent',
  };

  Color get color => switch (this) {
    TaskPriority.low => const Color(0xFF9E9E9E),    // Grey
    TaskPriority.medium => const Color(0xFF00E5FF), // Blue / Cyan
    TaskPriority.high => const Color(0xFFFF9100),   // Orange
    TaskPriority.urgent => const Color(0xFFFF5252), // Red
  };

  int get weight => switch (this) {
    TaskPriority.urgent => 4,
    TaskPriority.high => 3,
    TaskPriority.medium => 2,
    TaskPriority.low => 1,
  };

  static TaskPriority fromString(String? value) {
    return switch (value?.toLowerCase().trim()) {
      'urgent' || 'asap' || 'critical' => TaskPriority.urgent,
      'high' => TaskPriority.high,
      'low' => TaskPriority.low,
      _ => TaskPriority.medium,
    };
  }

  String toDbString() => name;
}
