import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    if (saved == 'dark') state = ThemeMode.dark;
    if (saved == 'light') state = ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      await prefs.setString('themeMode', 'dark');
    } else if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setString('themeMode', 'light');
    } else {
      // если system, то переключаем на светлую
      state = ThemeMode.light;
      await prefs.setString('themeMode', 'light');
    }
  }
}