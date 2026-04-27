import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../models/step.dart';
import 'api_provider.dart';

final goalProvider = StateNotifierProvider.autoDispose<GoalNotifier, Goal?>((ref) {
  return GoalNotifier(ref);
});

class GoalNotifier extends StateNotifier<Goal?> {
  final Ref _ref;
  GoalNotifier(this._ref) : super(null);

  Future<void> fetchGoal(int goalId) async {
    final apiClient = _ref.read(apiClientProvider);
    final response = await apiClient.get('/goals/$goalId');
    state = Goal.fromJson(response.data);
  }

  Future<void> toggleStep(int stepId, bool isCompleted) async {
    if (state == null) return;
    final apiClient = _ref.read(apiClientProvider);
    // Отправляем запрос на сервер (мок его обработает)
    await apiClient.patch('/steps/$stepId', data: {'is_completed': isCompleted});
    
    // Обновляем локальное состояние шагов
    final updatedSteps = state!.steps.map((step) {
      if (step.id == stepId) {
        return GoalStep(
          id: step.id,
          goalId: step.goalId,
          text: step.text,
          isCompleted: isCompleted,
          order: step.order,
        );
      }
      return step;
    }).toList();
    
    // Пересчитываем прогресс цели
    final newProgress = _recalculateProgress(updatedSteps);
    
    // Обновляем состояние (используем copyWith)
    state = state!.copyWith(steps: updatedSteps, progress: newProgress);
  }

  int _recalculateProgress(List<GoalStep> steps) {
    if (steps.isEmpty) return 0;
    final completed = steps.where((s) => s.isCompleted).length;
    return (completed / steps.length * 100).round();
  }
}