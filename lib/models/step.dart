class GoalStep {
  final int id;
  final int goalId;
  final String text;
  final bool isCompleted;
  final int order;

  GoalStep({
    required this.id,
    required this.goalId,
    required this.text,
    required this.isCompleted,
    required this.order,
  });

  factory GoalStep.fromJson(Map<String, dynamic> json) {
    return GoalStep(
      id: json['id'],
      goalId: json['goal_id'],
      text: json['text'],
      isCompleted: json['is_completed'] ?? false,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'text': text,
      'is_completed': isCompleted,
      'order': order,
    };
  }
}