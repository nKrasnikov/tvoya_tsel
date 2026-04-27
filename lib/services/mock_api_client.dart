import 'dart:convert';
import 'package:dio/dio.dart';

class MockApiClient {
  static const bool useMock = true; // можно переключать

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // имитация задержки сети
    if (path.startsWith('/goals/') && path != '/goals/') {
      // детальная цель по ID
      final goalId = int.parse(path.split('/').last);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _getGoalById(goalId),
        statusCode: 200,
      );
    }
    if (path == '/goals/') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _getGoalsList(),
        statusCode: 200,
      );
    }
    if (path == '/users/me') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _getCurrentUser(),
        statusCode: 200,
      );
    }
    if (path == '/admin/users') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _getAdminUsers(),
        statusCode: 200,
      );
    }
    if (path == '/admin/llm-logs') {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _getLlmLogs(),
        statusCode: 200,
      );
    }
    // ... добавить другие эндпоинты по необходимости
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Mock response for $path'},
      statusCode: 200,
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (path == '/auth/login') {
      final email = data['email'];
      final password = data['password'];
      if (email == 'admin@example.com' && password == 'admin123') {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {
            'access_token': 'mock_access_token',
            'refresh_token': 'mock_refresh_token',
            'user': _getAdminUser(),
          },
          statusCode: 200,
        );
      } else if (email == 'user@example.com' && password == 'user123') {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {
            'access_token': 'mock_access_token',
            'refresh_token': 'mock_refresh_token',
            'user': _getRegularUser(),
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
        data: {'message': 'User registered', 'user': _getRegularUser()},
        statusCode: 201,
      );
    }
    if (path.startsWith('/goals/') && path.endsWith('/generate-steps')) {
      final goalId = int.parse(path.split('/')[2]);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _generateMockSteps(goalId),
        statusCode: 200,
      );
    }
    if (path.startsWith('/goals/') && path.endsWith('/advice')) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {'advice': 'Это мок-совет. Попробуйте разбить задачу на более мелкие шаги и выполнять по одному в день.'},
        statusCode: 200,
      );
    }
    if (path == '/goals/') {
      // создание цели
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {'id': 999, 'title': data['title'], 'description': data['description'], 'progress': 0, 'steps': []},
        statusCode: 201,
      );
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Mock POST success'},
      statusCode: 200,
    );
  }

  Future<Response> put(String path, {dynamic data}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Updated'},
      statusCode: 200,
    );
  }

  Future<Response> patch(String path, {dynamic data}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Patched'},
      statusCode: 200,
    );
  }

  Future<Response> delete(String path) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Deleted'},
      statusCode: 200,
    );
  }

  // ---- МОК-ДАННЫЕ ----
  Map<String, dynamic> _getCurrentUser() {
    return {
      'id': 1,
      'email': 'user@example.com',
      'full_name': 'Тестовый Пользователь',
      'role': 'user',
      'is_blocked': false,
    };
  }

  Map<String, dynamic> _getAdminUser() {
    return {
      'id': 2,
      'email': 'admin@example.com',
      'full_name': 'Admin User',
      'role': 'admin',
      'is_blocked': false,
    };
  }

  Map<String, dynamic> _getRegularUser() {
    return {
      'id': 3,
      'email': 'user@example.com',
      'full_name': 'Обычный Пользователь',
      'role': 'user',
      'is_blocked': false,
    };
  }

  List<Map<String, dynamic>> _getGoalsList() {
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

  Map<String, dynamic> _getGoalById(int id) {
    final goals = _getGoalsList();
    return goals.firstWhere((g) => g['id'] == id, orElse: () => {});
  }

  List<Map<String, dynamic>> _generateMockSteps(int goalId) {
    return [
      {'id': 1001, 'goal_id': goalId, 'text': 'Сгенерированный шаг 1', 'is_completed': false, 'order': 0},
      {'id': 1002, 'goal_id': goalId, 'text': 'Сгенерированный шаг 2', 'is_completed': false, 'order': 1},
      {'id': 1003, 'goal_id': goalId, 'text': 'Сгенерированный шаг 3', 'is_completed': false, 'order': 2},
    ];
  }

  List<Map<String, dynamic>> _getAdminUsers() {
    return [
      {'id': 1, 'email': 'user@example.com', 'full_name': 'User', 'role': 'user', 'is_blocked': false},
      {'id': 2, 'email': 'admin@example.com', 'full_name': 'Admin', 'role': 'admin', 'is_blocked': false},
    ];
  }

  List<Map<String, dynamic>> _getLlmLogs() {
    return [
      {'request_type': 'generate_steps', 'prompt': 'Разбей цель...', 'duration_ms': 1200, 'success': true},
      {'request_type': 'advice', 'prompt': 'Как не прокрастинировать?', 'duration_ms': 800, 'success': true},
    ];
  }
}