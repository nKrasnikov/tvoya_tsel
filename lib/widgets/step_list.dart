import 'package:flutter/material.dart';
import '../models/step.dart' as Model; // алиас для модели Step

class StepList extends StatelessWidget {
  final List<Model.Step> steps;
  final Function(int, bool) onToggle;

  const StepList({super.key, required this.steps, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (ctx, i) {
        final step = steps[i];
        return CheckboxListTile(
          title: Text(step.text),
          value: step.isCompleted,
          onChanged: (value) => onToggle(step.id, value ?? false),
        );
      },
    );
  }
}