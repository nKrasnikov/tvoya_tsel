import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../models/step.dart';
import 'api_provider.dart';

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier(ref);
});

class GoalsNotifier extends StateNotifier<List<Goal>> {
  final Ref _ref;
  GoalsNotifier(this._ref) : super([]);

  Future<void> fetchGoals({bool archived = false}) async {
    final apiClient = _ref.read(apiClientProvider);
    final response = await apiClient.get('/goals/', queryParams: {'archived': archived});
    final goals = (response.data as List).map((g) => Goal.fromJson(g)).toList();
    state = goals;
  }

  Future<void> createGoal(Map<String, dynamic> data) async {
    final apiClient = _ref.read(apiClientProvider);
    final response = await apiClient.post('/goals/', data: data);
    final newGoal = Goal.fromJson(response.data);
    state = [...state, newGoal];
  }

  Future<void> deleteGoal(int id) async {
    final apiClient = _ref.read(apiClientProvider);
    await apiClient.delete('/goals/$id');
    state = state.where((g) => g.id != id).toList();
  }

  Future<void> generateSteps(int goalId) async {
    final apiClient = _ref.read(apiClientProvider);
    final response = await apiClient.post('/goals/$goalId/generate-steps');
    final newSteps = (response.data as List).map((s) => GoalStep.fromJson(s)).toList();
    final index = state.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final updatedGoal = state[index].copyWith(steps: newSteps);
      state = [...state]..[index] = updatedGoal;
    }
  }
}