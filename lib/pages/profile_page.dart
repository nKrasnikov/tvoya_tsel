import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/api_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) _nameController.text = user.fullName;
  }

  Future<void> _updateProfile() async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.put('/users/me', data: {'full_name': _nameController.text.trim()});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль обновлён')));
  }

  Future<void> _changePassword() async {
    final oldPwd = _oldPasswordController.text.trim();
    final newPwd = _newPasswordController.text.trim();
    if (oldPwd.isEmpty || newPwd.isEmpty) return;
    final apiClient = ref.read(apiClientProvider);
    await apiClient.put('/users/me/password', data: {'old_password': oldPwd, 'new_password': newPwd});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пароль изменён')));
    _oldPasswordController.clear();
    _newPasswordController.clear();
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Личные данные', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Имя')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _updateProfile, child: const Text('Обновить профиль')),
          const Divider(height: 32),
          const Text('Смена пароля', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(controller: _oldPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Старый пароль')),
          TextField(controller: _newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Новый пароль')),
          ElevatedButton(onPressed: _changePassword, child: const Text('Сменить пароль')),
          const Divider(height: 32),
          const Text('Настройки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Тёмная тема'),
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const Divider(height: 32),
          ElevatedButton(onPressed: _logout, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Выйти')),
        ],
      ),
    );
  }
}