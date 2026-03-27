// lib/providers/task_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

// ── Repository provider ──────────────────────────────────────────────────────

/// Provides the single [TaskRepository] instance for the whole app.
/// Tests can override this with a fresh repository using [ProviderContainer].
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// ── Task list notifier ───────────────────────────────────────────────────────

/// [TaskListNotifier] wraps [TaskRepository] and exposes
/// the list of [Task]s as reactive Riverpod state.
class TaskListNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    // Initial state — delegate to the repository
    return ref.read(taskRepositoryProvider).tasks;
  }

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  void addTask(String title, String id) {
    final task = Task(id: id, title: title);
    state = _repo.addTask(task);
  }

  void deleteTask(String id) {
    state = _repo.deleteTask(id);
  }

  void toggleTask(String id) {
    final task = _repo.findById(id);
    if (task == null) return;
    state = _repo.updateTask(id, completed: !task.completed);
  }

  void updateTitle(String id, String newTitle) {
    state = _repo.updateTask(id, title: newTitle);
  }
}

/// The primary provider consumed by UI widgets.
final taskListProvider =
NotifierProvider<TaskListNotifier, List<Task>>(TaskListNotifier.new);