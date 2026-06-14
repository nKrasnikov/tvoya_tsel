import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl)) {
    if (!AppConfig.useMockApi) {
      _setupInterceptors();
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final newToken = await _refreshToken();
          if (newToken != null) {
            e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final cloneReq = await _dio.fetch(e.requestOptions);
            return handler.resolve(cloneReq);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return null;
      final response = await _dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
      final newAccessToken = response.data['access_token'];
      await _storage.write(key: 'access_token', value: newAccessToken);
      return newAccessToken;
    } catch (e) {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      return null;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    if (AppConfig.useMockApi) {
      return _mockGet(path, queryParams: queryParams);
    }
    return _dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) async {
    if (AppConfig.useMockApi) {
      return _mockPost(path, data: data);
    }
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    if (AppConfig.useMockApi) {
      return _mockPut(path, data: data);
    }
    return _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    if (AppConfig.useMockApi) {
      return _mockPatch(path, data: data);
    }
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    if (AppConfig.useMockApi) {
      return _mockDelete(path);
    }
    return _dio.delete(path);
  }

  Future<Response> _mockGet(String path, {Map<String, dynamic>? queryParams}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final storage = const FlutterSecureStorage();
    final accessToken = await storage.read(key: 'access_token');
    final isAdmin = accessToken?.contains('admin') ?? false;

    // Эндпоинт текущего пользователя
    if (path == '/users/me') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: isAdmin ? _mockAdminUser() : _mockCurrentUser(),
        statusCode: 200,
      );
    }

    // Админские эндпоинты
    if (path == '/admin/users') {
      if (!isAdmin) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {'detail': 'Forbidden'},
          statusCode: 403,
        );
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _mockAdminUsers(),
        statusCode: 200,
      );
    }

    if (path == '/admin/llm-logs') {
      if (!isAdmin) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {'detail': 'Forbidden'},
          statusCode: 403,
        );
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _mockLlmLogs(),
        statusCode: 200,
      );
    }

    // Список целей
    if (path == '/goals/') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _mockGoalsList(),
        statusCode: 200,
      );
    }

    // Конкретная цель по ID
    if (path.startsWith('/goals/') && path != '/goals/') {
      final id = int.parse(path.split('/').last);
      final goal = _mockGoalsList().firstWhere((g) => g['id'] == id, orElse: () => {});
      return Response(
        requestOptions: RequestOptions(path: path),
        data: goal,
        statusCode: 200,
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Mock GET $path not implemented'},
      statusCode: 200,
    );
  }

  Future<Response> _mockPost(String path, {dynamic data}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (path == '/auth/login') {
      final email = data['email'];
      final password = data['password'];
      if (email == 'admin@example.com' && password == 'admin123') {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {
            'access_token': 'mock_admin_token',
            'refresh_token': 'mock_refresh',
            'user': _mockAdminUser(),
          },
          statusCode: 200,
        );
      } else if (email == 'user@example.com' && password == 'user123') {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {
            'access_token': 'mock_user_token',
            'refresh_token': 'mock_refresh',
            'user': _mockCurrentUser(),
          },
          statusCode: 200,
        );
      } else {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {'detail': 'Неверный email или пароль'},
          statusCode: 401,
        );
      }
    }
    if (path == '/auth/register') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {'user': _mockCurrentUser()},
        statusCode: 201,
      );
    }
    if (path.startsWith('/goals/') && path.endsWith('/generate-steps')) {
      final goalId = int.parse(path.split('/')[2]);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _mockGeneratedSteps(goalId),
        statusCode: 200,
      );
    }
    if (path.startsWith('/goals/') && path.endsWith('/advice')) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {'advice': 'Это мок-совет. Постарайтесь выполнять по одному шагу в день!'},
        statusCode: 200,
      );
    }
    if (path == '/goals/') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {'id': 999, 'title': data['title'], 'description': data['description'], 'progress': 0, 'steps': []},
        statusCode: 201,
      );
    }
    if (path == '/admin/users/1/block') {
      return Response(requestOptions: RequestOptions(path: path), data: {'status': 'blocked'}, statusCode: 200);
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Mock POST success'},
      statusCode: 200,
    );
  }

  Future<Response> _mockPut(String path, {dynamic data}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (path == '/users/me') {
      return Response(requestOptions: RequestOptions(path: path), data: {'message': 'Profile updated'}, statusCode: 200);
    }
    if (path.startsWith('/goals/')) {
      return Response(requestOptions: RequestOptions(path: path), data: {'message': 'Goal updated'}, statusCode: 200);
    }
    // Изменение пароля
    if (path == '/users/me/password') {
      return Response(requestOptions: RequestOptions(path: path), data: {'message': 'Password changed'}, statusCode: 200);
    }
    return Response(requestOptions: RequestOptions(path: path), data: {'message': 'PUT mock'}, statusCode: 200);
  }

  Future<Response> _mockPatch(String path, {dynamic data}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (path.startsWith('/steps/')) {
      return Response(requestOptions: RequestOptions(path: path), data: {'message': 'Step updated'}, statusCode: 200);
    }
    return Response(requestOptions: RequestOptions(path: path), data: {'message': 'PATCH mock'}, statusCode: 200);
  }

  Future<Response> _mockDelete(String path) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (path.startsWith('/goals/')) {
      return Response(requestOptions: RequestOptions(path: path), data: {'message': 'Goal deleted'}, statusCode: 200);
    }
    return Response(requestOptions: RequestOptions(path: path), data: {'message': 'Deleted'}, statusCode: 200);
  }

  List<Map<String, dynamic>> _mockGoalsList() {
    return [
      {
        'id': 1,
        'title': 'Выучить Flutter',
        'description': 'Освоить разработку кроссплатформенных приложений',
        'deadline': '2026-06-01T00:00:00',
        'priority': 2,
        'progress': 30,
        'is_archived': false,
        'steps': [
          {'id': 101, 'goal_id': 1, 'text': 'Просмотреть документацию', 'is_completed': true, 'order': 0},
          {'id': 102, 'goal_id': 1, 'text': 'Сделать todo-приложение', 'is_completed': false, 'order': 1},
          {'id': 103, 'goal_id': 1, 'text': 'Изучить продвинутые темы', 'is_completed': false, 'order': 2},
        ],
      },
      {
        'id': 2,
        'title': 'Написать диплом',
        'description': 'Завершить ВКР к маю',
        'deadline': '2026-05-15T00:00:00',
        'priority': 3,
        'progress': 10,
        'is_archived': false,
        'steps': [
          {'id': 201, 'goal_id': 2, 'text': 'Собрать литературу', 'is_completed': true, 'order': 0},
          {'id': 202, 'goal_id': 2, 'text': 'Написать введение', 'is_completed': false, 'order': 1},
        ],
      },
    ];
  }

  Map<String, dynamic> _mockCurrentUser() {
    return {
      'id': 42,
      'email': 'user@example.com',
      'full_name': 'Тестовый Пользователь',
      'role': 'user',
      'is_blocked': false,
    };
  }

  Map<String, dynamic> _mockAdminUser() {
    return {
      'id': 1,
      'email': 'admin@example.com',
      'full_name': 'Администратор',
      'role': 'admin',
      'is_blocked': false,
    };
  }

  List<Map<String, dynamic>> _mockGeneratedSteps(int goalId) {
    return [
      {'id': 1001, 'goal_id': goalId, 'text': 'Сгенерированный шаг 1', 'is_completed': false, 'order': 0},
      {'id': 1002, 'goal_id': goalId, 'text': 'Сгенерированный шаг 2', 'is_completed': false, 'order': 1},
      {'id': 1003, 'goal_id': goalId, 'text': 'Сгенерированный шаг 3', 'is_completed': false, 'order': 2},
    ];
  }

  List<Map<String, dynamic>> _mockAdminUsers() {
    return [
      {'id': 1, 'email': 'admin@example.com', 'full_name': 'Администратор', 'role': 'admin', 'is_blocked': false},
      {'id': 42, 'email': 'user@example.com', 'full_name': 'Тестовый Пользователь', 'role': 'user', 'is_blocked': false},
    ];
  }

  List<Map<String, dynamic>> _mockLlmLogs() {
    return [
      {'request_type': 'generate_steps', 'prompt': 'Разбей цель...', 'duration_ms': 1200, 'success': true},
      {'request_type': 'advice', 'prompt': 'Как не прокрастинировать?', 'duration_ms': 800, 'success': true},
    ];
  }
}