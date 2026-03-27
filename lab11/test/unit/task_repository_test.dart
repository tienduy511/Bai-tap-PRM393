// test/unit/task_repository_test.dart
//
// Unit tests for TaskRepository CRUD logic.
// Uses plain Dart — no Flutter or Riverpod widgets needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/repositories/task_repository.dart';

void main() {
  late TaskRepository repository;

  setUp(() {
    // Fresh repository before every single test
    repository = TaskRepository();
  });

  // ── addTask() ────────────────────────────────────────────────────────────
  group('TaskRepository — addTask()', () {
    test('adds one task and length becomes 1', () {
      // Arrange
      final task = Task(id: 't1', title: 'First task');

      // Act
      repository.addTask(task);

      // Assert
      expect(repository.tasks.length, equals(1));
    });

    test('added task appears in the list', () {
      // Arrange
      final task = Task(id: 't2', title: 'My task');

      // Act
      repository.addTask(task);

      // Assert
      expect(repository.tasks.first.title, equals('My task'));
    });

    test('adding three tasks stores all three', () {
      // Arrange
      final tasks = [
        Task(id: 'a', title: 'Alpha'),
        Task(id: 'b', title: 'Beta'),
        Task(id: 'c', title: 'Gamma'),
      ];

      // Act
      for (final t in tasks) {
        repository.addTask(t);
      }

      // Assert
      expect(repository.tasks.length, equals(3));
    });

    test('tasks list is unmodifiable after add', () {
      // Arrange
      repository.addTask(Task(id: 'x', title: 'X'));

      // Act & Assert — direct mutation should throw
      expect(
            () => (repository.tasks as List).add(Task(id: 'y', title: 'Y')),
        throwsUnsupportedError,
      );
    });
  });

  // ── deleteTask() ─────────────────────────────────────────────────────────
  group('TaskRepository — deleteTask()', () {
    test('removes the correct task by id', () {
      // Arrange
      repository
        ..addTask(Task(id: 'd1', title: 'Keep'))
        ..addTask(Task(id: 'd2', title: 'Delete me'));

      // Act
      repository.deleteTask('d2');

      // Assert
      expect(repository.tasks.length, equals(1));
      expect(repository.tasks.first.id, equals('d1'));
    });

    test('deleting last task results in empty list', () {
      // Arrange
      repository.addTask(Task(id: 'only', title: 'Only one'));

      // Act
      repository.deleteTask('only');

      // Assert
      expect(repository.tasks, isEmpty);
    });

    test('deleting non-existent id does not throw', () {
      // Arrange — empty repo

      // Act & Assert
      expect(() => repository.deleteTask('ghost'), returnsNormally);
    });

    test('deleting does not affect unrelated tasks', () {
      // Arrange
      for (var i = 1; i <= 3; i++) {
        repository.addTask(Task(id: 'id-$i', title: 'Task $i'));
      }

      // Act
      repository.deleteTask('id-2');

      // Assert
      expect(repository.tasks.map((t) => t.id), containsAll(['id-1', 'id-3']));
      expect(repository.tasks.any((t) => t.id == 'id-2'), isFalse);
    });
  });

  // ── updateTask() ─────────────────────────────────────────────────────────
  group('TaskRepository — updateTask()', () {
    test('updates title of an existing task', () {
      // Arrange
      repository.addTask(Task(id: 'u1', title: 'Old title'));

      // Act
      repository.updateTask('u1', title: 'New title');

      // Assert
      expect(repository.findById('u1')?.title, equals('New title'));
    });

    test('updates completed status of an existing task', () {
      // Arrange
      repository.addTask(Task(id: 'u2', title: 'Task', completed: false));

      // Act
      repository.updateTask('u2', completed: true);

      // Assert
      expect(repository.findById('u2')?.completed, isTrue);
    });

    test('updates title and completed simultaneously', () {
      // Arrange
      repository.addTask(Task(id: 'u3', title: 'Old', completed: false));

      // Act
      repository.updateTask('u3', title: 'New', completed: true);

      // Assert
      expect(repository.findById('u3')?.title, equals('New'));
      expect(repository.findById('u3')?.completed, isTrue);
    });

    test('updateTask preserves fields that are not passed', () {
      // Arrange — task with completed=true
      repository.addTask(Task(id: 'u4', title: 'Keep status', completed: true));

      // Act — only update title
      repository.updateTask('u4', title: 'Changed title');

      // Assert — completed is still true
      expect(repository.findById('u4')?.completed, isTrue);
    });

    test('throws ArgumentError when id does not exist', () {
      // Arrange — empty repo

      // Act & Assert
      expect(
            () => repository.updateTask('nope', title: 'X'),
        throwsArgumentError,
      );
    });
  });

  // ── findById() ───────────────────────────────────────────────────────────
  group('TaskRepository — findById()', () {
    test('returns correct task by id', () {
      // Arrange
      repository.addTask(Task(id: 'find-me', title: 'Found'));

      // Act
      final result = repository.findById('find-me');

      // Assert
      expect(result?.title, equals('Found'));
    });

    test('returns null for missing id', () {
      // Arrange — empty repo

      // Act
      final result = repository.findById('missing');

      // Assert
      expect(result, isNull);
    });
  });
}