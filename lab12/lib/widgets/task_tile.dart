// lib/widgets/task_tile.dart
// Exercise 12.1 — Widget TaskTile được TÁCH RIÊNG để tránh rebuild toàn màn hình
//
// BEFORE: inline ListTile trong TaskListScreen → rebuild cả screen mỗi khi 1 task thay đổi
// AFTER:  StatelessWidget riêng với const constructor → chỉ rebuild tile liên quan

import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  // const constructor → Flutter có thể cache widget này
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: task.isDone ? Colors.green : Colors.grey,
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isDone ? TextDecoration.lineThrough : null,
          color: task.isDone ? Colors.grey : null,
        ),
      ),
      trailing: IconButton(
        // const Icon → tạo một lần duy nhất
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: onDelete,
        tooltip: 'Xóa task',
      ),
      onTap: onToggle,
    );
  }
}
