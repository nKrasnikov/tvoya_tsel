import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tvoya_tsel/providers/goals_provider.dart';
import 'package:tvoya_tsel/services/api_client.dart';
import 'package:tvoya_tsel/providers/api_provider.dart';

class MockApiClient implements ApiClient {
  List<Map<String, dynamic>> mockGoals = [
    {'id': 1, 'title': 'Goal 1', 'progress': 0, 'steps': []}
  ];

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    if (path == '/goals/') return mockGoals;
    throw Exception();
  }

  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    if (path == '/goals/') {
      return {'id': 2, 'title': data['title'], 'progress': 0, 'steps': []};
    }
    throw Exception();
  }
}

void main() {
  test('GoalsProvider fetchGoals loads goals', () async {
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWith((ref) => MockApiClient()),
    ]);
    final notifier = container.read(goalsProvider.notifier);
    await notifier.fetchGoals();
    final goals = container.read(goalsProvider);
    expect(goals.length, 1);
    expect(goals[0].title, 'Goal 1');
  });
}
