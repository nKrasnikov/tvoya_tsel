import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(authProvider.notifier).checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return MaterialApp(
      title: 'Твоя цель',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: authState.isAuthenticated ? const HomePage() : const LoginPage(),
    );
  }
}