// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final TextEditingController _controller = TextEditingController();
  int _idCounter = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _idCounter++;
    ref.read(taskListProvider.notifier).addTask(text, 'task-$_idCounter');
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Taskly')),
      body: Column(
        children: [
          // ── Input row ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('taskInputField'),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter task title',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  key: const Key('addTaskButton'),
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // ── Task list ────────────────────────────────────────
          Expanded(
            child: tasks.isEmpty
                ? const Center(
              key: Key('emptyState'),
              child: Text('No tasks yet. Add one!'),
            )
                : ListView.builder(
              key: const Key('taskList'),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  key: Key('task_${task.id}'),
                  title: Text(
                    task.title,
                    key: Key('taskTitle_${task.id}'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (_) => ref
                        .read(taskListProvider.notifier)
                        .toggleTask(task.id),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => ref
                        .read(taskListProvider.notifier)
                        .deleteTask(task.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TaskDetailScreen(taskId: task.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}