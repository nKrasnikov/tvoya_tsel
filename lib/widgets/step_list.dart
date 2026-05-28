import 'package:flutter/material.dart';
import '../models/step.dart';

class StepList extends StatelessWidget {
  final List<GoalStep> steps;
  final Function(int, bool) onToggle;
  final Function(int) onDelete;

  const StepList({
    super.key,
    required this.steps,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (ctx, i) {
        final step = steps[i];
        return ListTile(
          leading: Checkbox(
            value: step.isCompleted,
            onChanged: (value) => onToggle(step.id, value ?? false),
          ),
          title: Text(step.text),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(step.id),
          ),
        );
      },
    );
  }
}