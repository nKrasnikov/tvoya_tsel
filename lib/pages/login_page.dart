import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  await ref.read(authProvider.notifier).login(email, password);
}

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Твоя цель', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 40),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Пароль')),
            const SizedBox(height: 24),
            if (authState.isLoading) const CircularProgressIndicator(),
            if (authState.error != null) Text(authState.error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _login, child: const Text('Войти')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
              child: const Text('Нет аккаунта? Зарегистрируйтесь'),
            ),
          ],
        ),
      ),
    );
  }
}