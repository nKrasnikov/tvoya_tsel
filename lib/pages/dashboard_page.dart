import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goals_provider.dart';
import '../widgets/goal_card.dart';
import 'goal_edit_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    ref.read(goalsProvider.notifier).fetchGoals();
  }

  void _createGoal() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalEditPage()));
    if (result == true) {
      ref.read(goalsProvider.notifier).fetchGoals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Мои цели')),
      body: goals.isEmpty
          ? const Center(child: Text('У вас ещё нет целей. Создайте первую!'))
          : ListView.builder(
              itemCount: goals.length,
              itemBuilder: (ctx, i) => GoalCard(goal: goals[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGoal,
        child: const Icon(Icons.add),
      ),
    );
  }
}