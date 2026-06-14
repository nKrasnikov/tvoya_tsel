import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';
import '../providers/auth_provider.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _llmLogs = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadLogs();
  }

  Future<void> _loadUsers() async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/admin/users');
    setState(() => _users = List<Map<String, dynamic>>.from(response.data));
  }

  Future<void> _loadLogs() async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/admin/llm-logs');
    setState(() => _llmLogs = List<Map<String, dynamic>>.from(response.data));
  }

  Future<void> _toggleBlock(int userId, bool isBlocked) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post('/admin/users/$userId/block', data: {'block': !isBlocked});
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
  final user = ref.watch(authProvider).user;
  if (user?.role != 'admin') {
    return Scaffold(body: Center(child: Text('Доступ запрещён')));
  } 
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Админ-панель'),
          bottom: const TabBar(tabs: [Tab(text: 'Пользователи'), Tab(text: 'Логи LLM')]),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: _users.length,
              itemBuilder: (ctx, i) {
                final u = _users[i];
                return ListTile(
                  title: Text(u['email']),
                  subtitle: Text('Роль: ${u['role']} | Заблокирован: ${u['is_blocked']}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: u['is_blocked'] ? Colors.green : Colors.red),
                    onPressed: () => _toggleBlock(u['id'], u['is_blocked']),
                    child: Text(u['is_blocked'] ? 'Разблокировать' : 'Заблокировать'),
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: _llmLogs.length,
              itemBuilder: (ctx, i) {
                final log = _llmLogs[i];
                return Card(
                  child: ListTile(
                    title: Text(log['request_type'] ?? 'unknown'),
                    subtitle: Text('Промпт: ${log['prompt']?.substring(0, 50)}... длительность: ${log['duration_ms']} мс'),
                    trailing: Text(log['success'] ? 'Successed' : 'Failed'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}