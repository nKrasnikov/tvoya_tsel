import 'step.dart';

class Goal {
  final int id;
  final String title;
  final String? description;
  final DateTime? deadline;
  final int priority;
  final int progress;
  final bool isArchived;
  final List<Step> steps;

  Goal({
    required this.id,
    required this.title,
    this.description,
    this.deadline,
    required this.priority,
    required this.progress,
    required this.isArchived,
    this.steps = const [],
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      priority: json['priority'] ?? 1,
      progress: json['progress'] ?? 0,
      isArchived: json['is_archived'] ?? false,
      steps: (json['steps'] as List?)?.map((s) => Step.fromJson(s)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'priority': priority,
      'progress': progress,
      'is_archived': isArchived,
      'steps': steps.map((s) => s.toJson()).toList(),
    };
  }
}