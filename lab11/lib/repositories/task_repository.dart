// lib/repositories/task_repository.dart

import '../models/task.dart';

/// Pure-Dart repository for Task CRUD.
/// Holds state as an immutable list — every mutation returns a new list.
class TaskRepository {
  List<Task> _tasks;

  TaskRepository({List<Task>? initialTasks})
      : _tasks = initialTasks ?? const [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Adds [task] and returns the updated list.
  List<Task> addTask(Task task) {
    _tasks = [..._tasks, task];
    return tasks;
  }

  /// Removes task with [id] and returns the updated list.
  List<Task> deleteTask(String id) {
    _tasks = _tasks.where((t) => t.id != id).toList();
    return tasks;
  }

  /// Updates task with [id] — replaces title and/or completed.
  /// Throws [ArgumentError] if [id] is not found.
  List<Task> updateTask(String id, {String? title, bool? completed}) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw ArgumentError('Task not found: $id');
    final updated = _tasks[index].copyWith(title: title, completed: completed);
    _tasks = [..._tasks]..[index] = updated;
    return tasks;
  }

  /// Returns task by [id], or null if not found.
  Task? findById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clears all tasks (useful for test tearDown).
  void clear() => _tasks = const [];
}