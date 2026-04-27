import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../pages/goal_detail_page.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(goal.title),
        subtitle: Text('Прогресс: ${goal.progress}%'),
        trailing: Icon(goal.isArchived ? Icons.archive : Icons.check_circle_outline),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => GoalDetailPage(goalId: goal.id)));
        },
      ),
    );
  }
}