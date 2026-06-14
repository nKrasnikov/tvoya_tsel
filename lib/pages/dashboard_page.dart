import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goals_provider.dart';
import '../models/goal.dart';
import '../widgets/custom_goal_card.dart';
import '../widgets/search_bar.dart';
import 'goal_edit_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String _searchQuery = '';
  String _filter = 'all'; // all, in_progress, completed, paused, overdue

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
      case 'paused':
        return [];
      case 'overdue':
        return goals.where((g) => g.deadline != null && g.deadline!.isBefore(DateTime.now()) && g.progress < 100).toList();
      default:
        return goals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGoals = ref.watch(goalsProvider);
    final inProgress = allGoals.where((g) => g.progress > 0 && g.progress < 100 && !g.isArchived).length;
    final completed = allGoals.where((g) => g.progress == 100 || g.isArchived).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дашборд'),
        actions: [
          SearchField(
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статистические карточки
            Row(
              children: [
                _StatCard(title: 'Всего целей', value: allGoals.length, color: Colors.blue),
                _StatCard(title: 'В процессе', value: inProgress, color: Colors.orange),
                _StatCard(title: 'Завершено', value: completed, color: Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            // Фильтры
            _FilterChips(filter: _filter, onChanged: (value) => setState(() => _filter = value)),
            const SizedBox(height: 24),
            // Список целей
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredGoals.length + 1,
              itemBuilder: (ctx, i) {
                if (i == _filteredGoals.length) {
                  return const _AddGoalCard();
                }
                return CustomGoalCard(goal: _filteredGoals[i]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(value.toString(), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String filter;
  final Function(String) onChanged;

  const _FilterChips({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = {
      'all': 'Все',
      'in_progress': 'В процессе',
      'completed': 'Завершено',
      'paused': 'На паузе',
      'overdue': 'Просрочено',
    };
    return Wrap(
      spacing: 8,
      children: filters.entries.map((entry) {
        return FilterChip(
          label: Text(entry.value),
          selected: filter == entry.key,
          onSelected: (_) => onChanged(entry.key),
        );
      }).toList(),
    );
  }
}

class _AddGoalCard extends ConsumerWidget {
  const _AddGoalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GoalEditPage()),
          );
          if (result == true) {
            ref.read(goalsProvider.notifier).fetchGoals();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('Новая цель', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}