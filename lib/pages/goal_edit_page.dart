import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';

class GoalEditPage extends ConsumerStatefulWidget {
  final int? goalId;
  const GoalEditPage({super.key, this.goalId});

  @override
  ConsumerState<GoalEditPage> createState() => _GoalEditPageState();
}

class _GoalEditPageState extends ConsumerState<GoalEditPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _deadline;
  int _priority = 1;

  @override
  void initState() {
    super.initState();
    if (widget.goalId != null) {
      _loadGoal();
    }
  }

  Future<void> _loadGoal() async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/goals/${widget.goalId}');
    final goal = response.data;
    _titleController.text = goal['title'];
    _descController.text = goal['description'] ?? '';
    if (goal['deadline'] != null) _deadline = DateTime.parse(goal['deadline']);
    setState(() {
      _priority = goal['priority'] ?? 1;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    final apiClient = ref.read(apiClientProvider);
    final data = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'deadline': _deadline?.toIso8601String(),
      'priority': _priority,
    };
    if (widget.goalId == null) {
      await apiClient.post('/goals/', data: data);
    } else {
      await apiClient.put('/goals/${widget.goalId}', data: data);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.goalId == null ? 'Новая цель' : 'Редактировать цель')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Название цели')),
            const SizedBox(height: 16),
            TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Описание')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text(_deadline == null ? 'Дедлайн не выбран' : 'Дедлайн: ${_deadline!.toLocal().toString().split(' ')[0]}')),
                TextButton(onPressed: () => _selectDate(context), child: const Text('Выбрать дату')),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _priority,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Низкий приоритет')),
                DropdownMenuItem(value: 2, child: Text('Средний приоритет')),
                DropdownMenuItem(value: 3, child: Text('Высокий приоритет')),
              ],
              onChanged: (val) => setState(() => _priority = val!),
              decoration: const InputDecoration(labelText: 'Приоритет'),
            ),
            const Spacer(),
            ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}