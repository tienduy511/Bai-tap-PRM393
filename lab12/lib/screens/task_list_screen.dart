// lib/screens/task_list_screen.dart
// Exercise 12.1 — Màn hình danh sách dùng Selector thay vì Consumer
//
// ============================================================
// BEFORE (không tối ưu):
//   Consumer<TaskProvider>(
//     builder: (context, provider, child) {
//       return ListView.builder(...);  // rebuild TOÀN MÀN HÌNH
//     },
//   )
//
// AFTER (đã tối ưu):
//   Selector<TaskProvider, List<Task>>(
//     selector: (_, p) => p.tasks,    // chỉ lắng nghe tasks
//     builder: (_, tasks, __) { ... } // rebuild chỉ khi tasks thay đổi
//   )
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/add_task_dialog.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taskly'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Selector riêng cho badge đếm — chỉ rebuild phần này khi pendingCount đổi
        actions: [
          Selector<TaskProvider, int>(
            selector: (_, p) => p.pendingCount,
            builder: (_, count, __) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text(
                  '$count chưa xong',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.orange.shade100,
              ),
            ),
          ),
        ],
      ),
      // Selector: chỉ rebuild khi List<Task> thực sự thay đổi
      body: Selector<TaskProvider, List<Task>>(
        selector: (_, provider) => provider.tasks,
        builder: (context, tasks, __) {
          if (tasks.isEmpty) {
            // const widget — không bao giờ tạo lại
            return const EmptyStateWidget();
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(
                // ValueKey(task.id) → Flutter nhận diện đúng item khi list reorder/delete
                key: ValueKey(task.id),
                task: task,
                onToggle: () =>
                    context.read<TaskProvider>().toggleTask(task.id),
                onDelete: () =>
                    context.read<TaskProvider>().deleteTask(task.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddTaskDialog(),
        ),
        tooltip: 'Thêm task mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}
