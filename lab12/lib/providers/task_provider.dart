// lib/providers/task_provider.dart
// Exercise 12.1 — ChangeNotifier quản lý danh sách task
// Dùng notifyListeners() có chọn lọc để hạn chế rebuild không cần thiết

import 'package:flutter/foundation.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  /// Getter trả về bản sao read-only — tránh ngoài modify trực tiếp list
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Thêm task mới — id dùng timestamp để đảm bảo unique
  void addTask(String title) {
    if (title.trim().isEmpty) return;
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
    );
    _tasks.add(task);
    notifyListeners();
  }

  /// Toggle trạng thái done/undone của task theo id
  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    notifyListeners();
  }

  /// Xóa task theo id
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Số task chưa hoàn thành — dùng cho Selector riêng lẻ
  int get pendingCount => _tasks.where((t) => !t.isDone).length;
}
