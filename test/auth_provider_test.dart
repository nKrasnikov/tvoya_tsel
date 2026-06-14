import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tvoya_tsel/providers/auth_provider.dart';
import 'package:tvoya_tsel/services/api_client.dart';
import 'package:tvoya_tsel/providers/api_provider.dart';

class MockApiClient implements ApiClient {
  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    if (path == '/auth/login') {
      return {
        'access_token': 'fake_token',
        'refresh_token': 'fake_refresh',
        'user': {'id': 1, 'email': 'test@test.com', 'full_name': 'Test'}
      };
    }
    throw Exception('Not mocked');
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> put(String path, {dynamic data}) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> patch(String path, {dynamic data}) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> delete(String path) async {
    throw UnimplementedError();
  }
}

void main() {
  test('AuthProvider login sets isAuthenticated true', () async {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWith((ref) => MockApiClient()),
    ]);
    final notifier = container.read(authProvider.notifier);
    await notifier.login('test@test.com', 'pass');
    final state = container.read(authProvider);
    expect(state.isAuthenticated, true);
    expect(state.user?.email, 'test@test.com');
  });
}
