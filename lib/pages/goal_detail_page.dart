import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goals_provider.dart';
import '../widgets/step_list.dart';
import '../widgets/llm_chat.dart';

class GoalDetailPage extends ConsumerStatefulWidget {
  final int goalId;
  const GoalDetailPage({super.key, required this.goalId});

  @override
  ConsumerState<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends ConsumerState<GoalDetailPage> {
  @override
  void initState() {
    super.initState();
    _refreshGoal();
  }

  Future<void> _refreshGoal() async {
    await ref.read(goalsProvider.notifier).fetchGoals(); // упрощённо: лучше отдельный провайдер для одной цели
  }

  void _generateSteps() async {
    await ref.read(goalsProvider.notifier).generateSteps(widget.goalId);
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);
    final goal = goals.firstWhere((g) => g.id == widget.goalId, orElse: () => throw Exception('Goal not found'));
    return Scaffold(
      appBar: AppBar(title: Text(goal.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description ?? '', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: goal.progress / 100),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _generateSteps,
                  child: const Text('Сгенерировать шаги (LLM)'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Добавить шаг'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StepList(steps: goal.steps, onToggle: (stepId, isCompleted) {
              // вызывать API для обновления шага
            }),
            const SizedBox(height: 24),
            const Text('ИИ-советник', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            LLMChat(goalId: goal.id),
          ],
        ),
      ),
    );
  }
}