import 'step.dart';

class Goal {
  final int id;
  final String title;
  final String? description;
  final DateTime? deadline;
  final int priority;
  final int progress;
  final bool isArchived;
  final List<GoalStep> steps;

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
      steps: (json['steps'] as List?)?.map((s) => GoalStep.fromJson(s)).toList() ?? [],
    );
  }

  // Копирование с изменением полей
  Goal copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    int? priority,
    int? progress,
    bool? isArchived,
    List<GoalStep>? steps,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      isArchived: isArchived ?? this.isArchived,
      steps: steps ?? this.steps,
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