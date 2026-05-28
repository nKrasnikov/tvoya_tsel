import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../providers/api_provider.dart';
import '../models/user.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  DateTime? _birthDate;
  String? _gender;
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _interestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _birthDate = user.birthDate;
      _gender = user.gender;
      _cityController.text = user.city ?? '';
      _bioController.text = user.bio ?? '';
      _interestsController.text = user.interests ?? '';
    }
  }

  Future<void> _updateProfile() async {
    final apiClient = ref.read(apiClientProvider);
    final data = {
      'birth_date': _birthDate?.toIso8601String().split('T').first,
      'gender': _gender,
      'city': _cityController.text.trim(),
      'bio': _bioController.text.trim(),
      'interests': _interestsController.text.trim(),
    };
    try {
      await apiClient.put('/users/me', data: data);
      await ref.read(authProvider.notifier).fetchUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль обновлён')),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Ошибка обновления профиля';
      if (e.response?.statusCode == 422) {
        errorMessage = 'Проверьте правильность введённых данных';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final oldPwd = _oldPasswordController.text.trim();
    final newPwd = _newPasswordController.text.trim();
    if (oldPwd.isEmpty || newPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните оба поля пароля')),
      );
      return;
    }
    final apiClient = ref.read(apiClientProvider);
    try {
      await apiClient.put('/users/me/password', data: {
        'old_password': oldPwd,
        'new_password': newPwd,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароль изменён')),
        );
      }
      _oldPasswordController.clear();
      _newPasswordController.clear();
    } on DioException catch (e) {
      String errorMessage = 'Ошибка смены пароля';
      if (e.response?.statusCode == 400) {
        errorMessage = 'Неверный старый пароль';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Личная информация', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Имя'),
              subtitle: Text(user.fullName),
            ),
            const Divider(),
            ListTile(
              title: const Text('Дата рождения'),
              subtitle: Text(_birthDate != null ? '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}' : 'Не указана'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _birthDate = picked);
                  }
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Пол'),
              subtitle: Text(_gender == 'male' ? 'Мужской' : (_gender == 'female' ? 'Женский' : (_gender == 'other' ? 'Другой' : 'Не указан'))),
              trailing: DropdownButton<String>(
                value: _gender,
                hint: const Text('Выберите'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Мужской')),
                  DropdownMenuItem(value: 'female', child: Text('Женский')),
                  DropdownMenuItem(value: 'other', child: Text('Другой')),
                ],
                onChanged: (val) => setState(() => _gender = val),
              ),
            ),
            const SizedBox(height: 8),
            TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'Город')),
            const SizedBox(height: 16),
            TextField(controller: _bioController, maxLines: 2, decoration: const InputDecoration(labelText: 'О себе')),
            const SizedBox(height: 16),
            TextField(controller: _interestsController, maxLines: 2, decoration: const InputDecoration(labelText: 'Интересы (через запятую)')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Сохранить изменения'),
            ),
            const Divider(height: 32),
            const Text('Смена пароля', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Старый пароль'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Новый пароль'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Сменить пароль'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Выйти', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}