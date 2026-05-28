import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import '../providers/goals_provider.dart';
import '../models/goal.dart';
import '../models/step.dart';
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
  Goal? _goal;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/goals/${widget.goalId}');
    setState(() {
      _goal = Goal.fromJson(response.data);
    });
  }
  
  Future<void> _deleteGoal() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить цель?'),
        content: Text('Вы уверены, что хотите удалить цель "${_goal?.title}"? Все шаги также будут удалены.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.delete('/goals/${widget.goalId}');
      // Обновляем список целей на дашборде
      ref.read(goalsProvider.notifier).fetchGoals();
      if (mounted) Navigator.pop(context); // возвращаемся на дашборд
    }
  }

  Future<void> _toggleStep(int stepId, bool isCompleted) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.patch('/steps/$stepId', data: {'is_completed': isCompleted});
    await _loadGoal();
    await ref.read(goalsProvider.notifier).fetchGoals(); // обновляем дашборд
  }

  Future<void> _deleteStep(int stepId) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.delete('/steps/$stepId');
    await _loadGoal();
    await ref.read(goalsProvider.notifier).fetchGoals(); // обновляем дашборд
  }

  Future<void> _addStep() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новый шаг'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post('/goals/${widget.goalId}/steps', data: {'text': result});
      await _loadGoal();
    }
  }

  Future<void> _generateSteps() async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post('/goals/${widget.goalId}/generate-steps');
    await _loadGoal();
    await ref.read(goalsProvider.notifier).fetchGoals(); // обновляем дашборд
  }

  @override
  Widget build(BuildContext context) {
    if (_goal == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final goal = _goal!;
    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
        IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteGoal,
            tooltip: 'Удалить цель',
          ),
        ],
      ),
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
                ElevatedButton(onPressed: _generateSteps, child: const Text('Сгенерировать шаги (LLM)')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addStep, child: const Text('Добавить шаг')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Шаги:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StepList(
              steps: goal.steps,
              onToggle: _toggleStep,
              onDelete: _deleteStep,
            ),
            const SizedBox(height: 24),
            const Text('ИИ-советник', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            LLMChat(goalId: goal.id),
          ],
        ),
      ),
    );
  }
}