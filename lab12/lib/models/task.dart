// lib/models/task.dart
// Exercise 12.1 — Model dữ liệu Task với id duy nhất để dùng ValueKey

class Task {
  final String id;
  final String title;
  final bool isDone;

  const Task({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  /// Tạo bản sao với các trường cập nhật — giúp Selector phát hiện thay đổi
  Task copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Task &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              isDone == other.isDone;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ isDone.hashCode;

  @override
  String toString() => 'Task(id: $id, title: $title, isDone: $isDone)';
}
