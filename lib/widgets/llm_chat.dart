import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';

class LLMChat extends ConsumerStatefulWidget {
  final int goalId;
  const LLMChat({super.key, required this.goalId});

  @override
  ConsumerState<LLMChat> createState() => _LLMChatState();
}

class _LLMChatState extends ConsumerState<LLMChat> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': question});
      _controller.clear();
    });
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/goals/${widget.goalId}/advice', data: {'question': question});
      final advice = response.data['advice'];
      setState(() {
        _messages.add({'role': 'assistant', 'text': advice});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'Не удалось получить ответ. Попробуйте позже.'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (ctx, i) {
              final msg = _messages[i];
              return Align(
                alignment: msg['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: msg['role'] == 'user' ? Colors.blue.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(msg['text']!),
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Задайте вопрос...'))),
            IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
          ],
        ),
      ],
    );
  }
}