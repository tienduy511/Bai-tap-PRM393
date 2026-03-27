// lib/models/task.dart

/// Immutable Task model.
/// Use [copyWith] to produce modified copies — never mutate directly.
class Task {
  final String id;
  final String title;
  final bool completed;

  const Task({
    required this.id,
    required this.title,
    this.completed = false,
  });

  /// Returns a new Task with [completed] flipped.
  Task toggle() => copyWith(completed: !completed);

  /// Returns a copy of this task with optional field overrides.
  Task copyWith({String? title, bool? completed}) {
    return Task(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Task && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Task(id: $id, title: $title, completed: $completed)';
}