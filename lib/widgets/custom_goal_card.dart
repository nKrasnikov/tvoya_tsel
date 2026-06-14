import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../widgets/progress_bar.dart';
import '../pages/goal_detail_page.dart';

class CustomGoalCard extends StatelessWidget {
  final Goal goal;
  const CustomGoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    //bool isOverdue = goal.deadline != null && goal.deadline!.isBefore(DateTime.now()) && goal.progress < 100;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GoalDetailPage(goalId: goal.id)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (goal.priority == 3)
                    const Icon(Icons.flag, color: Colors.red, size: 16),
                  if (goal.priority == 2)
                    const Icon(Icons.flag, color: Colors.orange, size: 16),
                  if (goal.priority == 1)
                    const Icon(Icons.flag_outlined, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ProgressBar(progress: goal.progress, height: 6),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${goal.steps.length} шагов', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  Text('${goal.progress}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}