import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goals_provider.dart';
import '../providers/api_provider.dart';

class AiAdvisorPage extends ConsumerStatefulWidget {
  const AiAdvisorPage({super.key});

  @override
  ConsumerState<AiAdvisorPage> createState() => _AiAdvisorPageState();
}

class _AiAdvisorPageState extends ConsumerState<AiAdvisorPage> {
  int? _selectedGoalId;
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goalsProvider.notifier).fetchGoals();
    });
  }

  Future<void> _sendQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _selectedGoalId == null) return;
    setState(() {
      _messages.add({'role': 'user', 'text': question});
      _questionController.clear();
      _isLoading = true;
    });
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/goals/$_selectedGoalId/advice', data: {'question': question});
      final advice = response.data['advice'];
      setState(() {
        _messages.add({'role': 'assistant', 'text': advice});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'Ошибка: не удалось получить ответ.'});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ИИ-советник')),
      body: Column(
        children: [
          // Выбор цели
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int>(
              value: _selectedGoalId,
              decoration: const InputDecoration(labelText: 'Выберите цель'),
              items: goals.map((goal) {
                return DropdownMenuItem(value: goal.id, child: Text(goal.title));
              }).toList(),
              onChanged: (id) => setState(() => _selectedGoalId = id),
            ),
          ),
          // Чат
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length && _isLoading) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final msg = _messages[i];
                return Align(
                  alignment: msg['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg['role'] == 'user' ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text']!),
                  ),
                );
              },
            ),
          ),
          // Поле ввода
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(hintText: 'Задайте вопрос...'),
                  ),
                ),
                IconButton(onPressed: _sendQuestion, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}