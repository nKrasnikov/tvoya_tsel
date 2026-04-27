// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/side_menu.dart';
import 'dashboard_page.dart';
import 'my_goals_page.dart';
import 'ai_advisor_page.dart';
import 'notifications_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'admin_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.role == 'admin';

    // Формируем список страниц в зависимости от роли
    final List<Widget> pages = [
      const DashboardPage(),
      const MyGoalsPage(),
      const AiAdvisorPage(),
      const NotificationsPage(),
      const StatisticsPage(),
      const ProfilePage(),
      const SettingsPage(),
      if (isAdmin) const AdminPage(), // добавляем админку только для админа
    ];

    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(child: pages[_selectedIndex]),
        ],
      ),
    );
  }
}