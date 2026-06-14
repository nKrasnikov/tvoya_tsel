import 'package:flutter_test/flutter_test.dart';
import 'package:tvoya_tsel/models/step.dart';

int calculateProgress(List<GoalStep> steps) {
  if (steps.isEmpty) return 0;
  final completed = steps.where((s) => s.isCompleted).length;
  return (completed / steps.length * 100).round();
}

void main() {
  test('Progress calculation returns 0 for empty steps', () {
    expect(calculateProgress([]), 0);
  });

  test('Progress calculation works for 2/5 steps', () {
    final steps = [
      GoalStep(id: 1, goalId: 1, text: 's1', isCompleted: true, order: 0),
      GoalStep(id: 2, goalId: 1, text: 's2', isCompleted: false, order: 1),
      GoalStep(id: 3, goalId: 1, text: 's3', isCompleted: false, order: 2),
      GoalStep(id: 4, goalId: 1, text: 's4', isCompleted: true, order: 3),
      GoalStep(id: 5, goalId: 1, text: 's5', isCompleted: false, order: 4),
    ];
    expect(calculateProgress(steps), 40);
  });

  test('Progress returns 100 when all completed', () {
    final steps = [
      GoalStep(id: 1, goalId: 1, text: 's1', isCompleted: true, order: 0),
      GoalStep(id: 2, goalId: 1, text: 's2', isCompleted: true, order: 1),
    ];
    expect(calculateProgress(steps), 100);
  });
}
