import 'package:flutter_test/flutter_test.dart';
import 'package:tvoya_tsel/models/goal.dart';
import 'package:tvoya_tsel/models/step.dart';

void main() {
  test('Goal fromJson parses steps correctly', () {
    final json = {
      'id': 1,
      'title': 'Test Goal',
      'description': 'desc',
      'progress': 50,
      'is_archived': false,
      'steps': [
        {'id': 1, 'goal_id': 1, 'text': 'Step1', 'is_completed': true, 'order': 0},
        {'id': 2, 'goal_id': 1, 'text': 'Step2', 'is_completed': false, 'order': 1},
      ]
    };
    final goal = Goal.fromJson(json);
    expect(goal.title, 'Test Goal');
    expect(goal.steps.length, 2);
    expect(goal.steps[0].isCompleted, true);
  });

  test('Goal copyWith works', () {
    final goal = Goal(
      id: 1,
      title: 'Original',
      description: '',
      priority: 1,
      progress: 0,
      isArchived: false,
      steps: [],
    );
    final updated = goal.copyWith(title: 'New Title', progress: 100);
    expect(updated.title, 'New Title');
    expect(updated.progress, 100);
    expect(updated.id, goal.id);
  });
}
