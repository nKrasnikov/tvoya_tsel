import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_provider.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    this.user,
    this.isLoading = false,
    this.error,
  });

  factory AuthState.initial() => AuthState(isAuthenticated: false, isLoading: false);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = AuthState(isAuthenticated: false, isLoading: true, error: null);
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];
      await _ref.read(secureStorageProvider).write(key: 'access_token', value: accessToken);
      await _ref.read(secureStorageProvider).write(key: 'refresh_token', value: refreshToken);

      // Получаем данные пользователя отдельным запросом
      final userResponse = await apiClient.get('/users/me');
      final user = User.fromJson(userResponse.data);

      state = AuthState(isAuthenticated: true, user: user, isLoading: false);
    } catch (e) {
      String errorMessage = 'Ошибка входа';
      if (e is DioException && e.response?.statusCode == 401) {
        errorMessage = 'Неверный email или пароль';
      }
      state = AuthState(isAuthenticated: false, isLoading: false, error: errorMessage);
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    state = AuthState(isAuthenticated: false, isLoading: true, error: null);
    try {
      final apiClient = _ref.read(apiClientProvider);
      await apiClient.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      });
      state = AuthState(isAuthenticated: false, isLoading: false);
    } catch (e) {
      String errorMessage = 'Ошибка регистрации';
      if (e is DioException && e.response?.statusCode == 400) {
        errorMessage = 'Пользователь с таким email уже существует';
      }
      state = AuthState(isAuthenticated: false, isLoading: false, error: errorMessage);
    }
  }

  Future<void> logout() async {
    await _ref.read(secureStorageProvider).delete(key: 'access_token');
    await _ref.read(secureStorageProvider).delete(key: 'refresh_token');
    state = AuthState(isAuthenticated: false);
  }

  Future<void> checkAuth() async {
    final token = await _ref.read(secureStorageProvider).read(key: 'access_token');
    if (token == null) {
      state = AuthState(isAuthenticated: false);
      return;
    }
    state = AuthState(isAuthenticated: true, isLoading: true);
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.get('/users/me');
      final user = User.fromJson(response.data);
      state = AuthState(isAuthenticated: true, user: user, isLoading: false);
    } catch (e) {
      await logout();
      state = AuthState(isAuthenticated: false);
    }
  }

  Future<void> fetchUser() async {
    final apiClient = _ref.read(apiClientProvider);
    final response = await apiClient.get('/users/me');
    final user = User.fromJson(response.data);
    state = AuthState(isAuthenticated: true, user: user, isLoading: false);
  }
}