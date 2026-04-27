import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SideMenu extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      // Пока пользователь не загружен – показываем заглушку (или спиннер)
      return Container(width: 260, color: Colors.grey.shade50);
    }

    // В методе build после получения user строим список items
    final navItems = <MenuItem>[
      const MenuItem(icon: Icons.dashboard, label: 'Дашборд', index: 0),
      const MenuItem(icon: Icons.list_alt, label: 'Мои цели', index: 1),
      const MenuItem(icon: Icons.psychology, label: 'ИИ-советник', index: 2),
      const MenuItem(icon: Icons.notifications, label: 'Уведомления', index: 3),
      const MenuItem(icon: Icons.bar_chart, label: 'Статистика', index: 4),
    ];

    final accountItems = <MenuItem>[
      const MenuItem(icon: Icons.person, label: 'Профиль', index: 5),
      const MenuItem(icon: Icons.settings, label: 'Настройки', index: 6),
    ];

    // Если пользователь администратор, добавляем пункт админ-панели в аккаунт (или в навигацию)
    List<MenuItem> finalAccountItems = List.from(accountItems);
    if (user.role == 'admin') {
      finalAccountItems.add(const MenuItem(icon: Icons.admin_panel_settings, label: 'Админ-панель', index: 7));
    }

    // Определяем статус аккаунта
    String accountStatus;
    Color statusColor;
    if (user.role == 'admin') {
      accountStatus = 'Администратор';
      statusColor = Colors.red;
    } else if (user.isPro == true) { // если в модели User добавить поле isPro
      accountStatus = 'Pro аккаунт';
      statusColor = Colors.green;
    } else {
      accountStatus = 'Обычный аккаунт';
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
                Text(
                  'Твоя цель',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),

          // Раздел "Навигация"
          _buildMenuGroup(
            context,
            title: 'Навигация',
            items: const [
              MenuItem(icon: Icons.dashboard, label: 'Дашборд', index: 0),
              MenuItem(icon: Icons.list_alt, label: 'Мои цели', index: 1),
              MenuItem(icon: Icons.psychology, label: 'ИИ-советник', index: 2),
              MenuItem(icon: Icons.notifications, label: 'Уведомления', index: 3),
              MenuItem(icon: Icons.bar_chart, label: 'Статистика', index: 4),
            ],
          ),

          const SizedBox(height: 16),

          // Раздел "Аккаунт"
          _buildMenuGroup(
            context,
            title: 'Аккаунт',
            items: const [
              MenuItem(icon: Icons.person, label: 'Профиль', index: 5),
              MenuItem(icon: Icons.settings, label: 'Настройки', index: 6),
            ],
          ),

          const Spacer(),

          // Информация о пользователе внизу (аватар, имя, статус)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Аватар (круглая заглушка, в будущем можно заменить на фото)
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        accountStatus,
                        style: TextStyle(fontSize: 12, color: statusColor),
                      ),
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

  Widget _buildMenuGroup(BuildContext context,
      {required String title, required List<MenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map((item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              selected: selectedIndex == item.index,
              selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
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