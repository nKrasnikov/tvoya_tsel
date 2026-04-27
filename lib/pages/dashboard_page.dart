import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goals_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/goal_card.dart';
import 'goal_edit_page.dart';
import 'profile_page.dart';
import 'admin_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _refreshGoals();
  }

  Future<void> _refreshGoals() async {
    await ref.read(goalsProvider.notifier).fetchGoals();
  }

  Future<void> _createGoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GoalEditPage()),
    );
    if (result == true) {
      _refreshGoals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Твоя цель'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            tooltip: 'Профиль',
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage())),
              tooltip: 'Админ-панель',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGoals,
        child: goals.isEmpty
            ? const Center(child: Text('У вас ещё нет целей. Создайте первую!'))
            : ListView.builder(
                itemCount: goals.length,
                itemBuilder: (ctx, i) => GoalCard(goal: goals[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGoal,
        child: const Icon(Icons.add),
      ),
    );
  }
}