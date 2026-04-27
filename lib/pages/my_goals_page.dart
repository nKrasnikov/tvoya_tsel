// lib/pages/my_goals_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goals_provider.dart';
import '../models/goal.dart';
import '../widgets/custom_goal_card.dart';
import '../widgets/search_bar.dart';

class MyGoalsPage extends ConsumerStatefulWidget {
  const MyGoalsPage({super.key});

  @override
  ConsumerState<MyGoalsPage> createState() => _MyGoalsPageState();
}

class _MyGoalsPageState extends ConsumerState<MyGoalsPage> {
  String _searchQuery = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goalsProvider.notifier).fetchGoals();
    });
  }

  List<Goal> get _filteredGoals {
    var goals = ref.watch(goalsProvider);
    if (_searchQuery.isNotEmpty) {
      goals = goals.where((g) => g.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    switch (_filter) {
      case 'in_progress':
        return goals.where((g) => g.progress > 0 && g.progress < 100 && !g.isArchived).toList();
      case 'completed':
        return goals.where((g) => g.progress == 100 || g.isArchived).toList();
      case 'overdue':
        return goals.where((g) => g.deadline != null && g.deadline!.isBefore(DateTime.now()) && g.progress < 100).toList();
      default:
        return goals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = _filteredGoals;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои цели'),
        actions: [
          SearchField(onChanged: (v) => setState(() => _searchQuery = v)),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: ['all', 'in_progress', 'completed', 'overdue'].map((f) {
                return FilterChip(
                  label: Text(_filterLabel(f)),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: goals.length,
              itemBuilder: (ctx, i) => CustomGoalCard(goal: goals[i]),
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(String filter) {
    switch (filter) {
      case 'all': return 'Все';
      case 'in_progress': return 'В процессе';
      case 'completed': return 'Завершено';
      case 'overdue': return 'Просрочено';
      default: return filter;
    }
  }
}