import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/api_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _reminderEnabled = true;
  TimeOfDay? _reminderTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = ref.read(authProvider).user;
    if (user != null) {
      setState(() {
        _reminderEnabled = true;
        _reminderTime = const TimeOfDay(hour: 9, minute: 0);
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.put('/users/me/settings', data: {
        'reminder_enabled': _reminderEnabled,
        'reminder_time': _reminderTime?.format(context),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Настройки сохранены')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: const Text('Тёмная тема'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Напоминания о шагах'),
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                ),
                if (_reminderEnabled)
                  ListTile(
                    title: const Text('Время напоминания'),
                    subtitle: Text(_reminderTime?.format(context) ?? 'Не выбрано'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final newTime = await showTimePicker(context: context, initialTime: _reminderTime ?? TimeOfDay.now());
                      if (newTime != null) setState(() => _reminderTime = newTime);
                    },
                  ),
                const SizedBox(height: 32),
                ElevatedButton(onPressed: _saveSettings, child: const Text('Сохранить настройки')),
              ],
            ),
    );
  }
}