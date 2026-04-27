import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SideMenu extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const SizedBox(width: 260);
    }

    final isAdmin = user.role == 'admin';

    // Пункты навигации (индексы 0-4)
    final navItems = const [
      MenuItem(icon: Icons.dashboard, label: 'Дашборд', index: 0),
      MenuItem(icon: Icons.list_alt, label: 'Мои цели', index: 1),
      MenuItem(icon: Icons.psychology, label: 'ИИ-советник', index: 2),
      MenuItem(icon: Icons.notifications, label: 'Уведомления', index: 3),
      MenuItem(icon: Icons.bar_chart, label: 'Статистика', index: 4),
    ];

    // Пункты аккаунта (индексы 5-6, и 7 для админа)
    final accountItems = [
      const MenuItem(icon: Icons.person, label: 'Профиль', index: 5),
      const MenuItem(icon: Icons.settings, label: 'Настройки', index: 6),
      if (isAdmin) const MenuItem(icon: Icons.admin_panel_settings, label: 'Админ-панель', index: 7),
    ];

    // Определяем статус аккаунта для отображения внизу
    String status;
    Color statusColor;
    if (isAdmin) {
      status = 'Администратор';
      statusColor = Colors.red;
    } else {
      status = 'Обычный аккаунт';
      statusColor = Colors.grey;
    }

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Логотип и название
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag, color: Theme.of(context).primaryColor, size: 32),
                const SizedBox(width: 8),
                Text('Твоя цель', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const Divider(),
          _buildMenuGroup(context, title: 'Навигация', items: navItems),
          const SizedBox(height: 16),
          _buildMenuGroup(context, title: 'Аккаунт', items: accountItems),
          const Spacer(),
          // Информация о пользователе внизу
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(status, style: TextStyle(fontSize: 12, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, {required String title, required List<MenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ),
        ...items.map((item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              selected: selectedIndex == item.index,
              onTap: () => onItemSelected(item.index),
            )),
      ],
    );
  }
}

class MenuItem {
  final IconData icon;
  final String label;
  final int index;
  const MenuItem({required this.icon, required this.label, required this.index});
}