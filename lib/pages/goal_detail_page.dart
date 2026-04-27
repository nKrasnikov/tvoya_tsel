import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_provider.dart';
import '../providers/goals_provider.dart';
import '../widgets/step_list.dart';
import '../widgets/llm_chat.dart';
import '../widgets/progress_bar.dart';

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
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    await ref.read(goalProvider.notifier).fetchGoal(widget.goalId);
  }

  Future<void> _generateSteps() async {
    // Вызываем генерацию через goalsProvider (или напрямую через API)
    await ref.read(goalsProvider.notifier).generateSteps(widget.goalId);
    // После генерации перезагружаем цель, чтобы показать новые шаги
    await _loadGoal();
  }

  Future<void> _toggleStep(int stepId, bool isCompleted) async {
    await ref.read(goalProvider.notifier).toggleStep(stepId, isCompleted);
    // Обновляем список целей на дашборде, чтобы изменился прогресс
    await ref.read(goalsProvider.notifier).fetchGoals();
    setState(() {}); // Перерисовка страницы
  }

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(goalProvider);
    if (goal == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(goal.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description ?? '', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: ProgressBar(progress: goal.progress)),
                const SizedBox(width: 8),
                Text('${goal.progress}%'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _generateSteps,
                  child: const Text('Сгенерировать шаги (LLM)'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Добавить шаг вручную (можно реализовать диалог)
                  },
                  child: const Text('Добавить шаг'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Шаги:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StepList(steps: goal.steps, onToggle: _toggleStep),
            const SizedBox(height: 24),
            const Text('ИИ-советник', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            LLMChat(goalId: goal.id),
          ],
        ),
      ),
    );
  }
}