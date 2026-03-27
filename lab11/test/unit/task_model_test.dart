// test/unit/task_model_test.dart
//
// Unit tests for the immutable Task model.
// No Flutter or Riverpod dependency — pure Dart only.

import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/models/task.dart';

void main() {
  group('Task Model — defaults', () {
    test('completed defaults to false', () {
      // Arrange & Act
      final task = Task(id: '1', title: 'Buy groceries');

      // Assert
      expect(task.completed, isFalse);
    });

    test('title is stored correctly', () {
      // Arrange & Act
      final task = Task(id: '2', title: 'Walk the dog');

      // Assert
      expect(task.title, equals('Walk the dog'));
    });

    test('id is stored correctly', () {
      // Arrange & Act
      final task = Task(id: 'abc-123', title: 'Test');

      // Assert
      expect(task.id, equals('abc-123'));
    });
  });

  group('Task Model — toggle()', () {
    test('toggle() switches false → true', () {
      // Arrange
      final task = Task(id: '3', title: 'Exercise');

      // Act
      final toggled = task.toggle();

      // Assert
      expect(toggled.completed, isTrue);
    });

    test('toggle() switches true → false', () {
      // Arrange
      final task = Task(id: '4', title: 'Read book', completed: true);

      // Act
      final toggled = task.toggle();

      // Assert
      expect(toggled.completed, isFalse);
    });

    test('toggle() twice returns to original value', () {
      // Arrange
      final task = Task(id: '5', title: 'Study');

      // Act
      final result = task.toggle().toggle();

      // Assert
      expect(result.completed, isFalse);
    });

    test('toggle() does NOT mutate the original task', () {
      // Arrange
      final original = Task(id: '6', title: 'Immutable check');

      // Act
      original.toggle(); // discard result

      // Assert — original is unchanged
      expect(original.completed, isFalse);
    });

    test('toggle() preserves id and title', () {
      // Arrange
      final task = Task(id: 'preserve-me', title: 'Keep this title');

      // Act
      final toggled = task.toggle();

      // Assert
      expect(toggled.id, equals('preserve-me'));
      expect(toggled.title, equals('Keep this title'));
    });
  });

  group('Task Model — copyWith()', () {
    test('copyWith(title:) creates new task with updated title', () {
      // Arrange
      final original = Task(id: '7', title: 'Old title');

      // Act
      final copy = original.copyWith(title: 'New title');

      // Assert
      expect(copy.title, equals('New title'));
      expect(copy.id, equals(original.id));
    });

    test('copyWith(completed:) creates new task with updated completed', () {
      // Arrange
      final original = Task(id: '8', title: 'Task');

      // Act
      final copy = original.copyWith(completed: true);

      // Assert
      expect(copy.completed, isTrue);
    });

    test('copyWith() does not mutate the original task', () {
      // Arrange
      final original = Task(id: '9', title: 'Original');

      // Act
      original.copyWith(title: 'Should not affect original');

      // Assert
      expect(original.title, equals('Original'));
    });

    test('copyWith() without arguments returns equivalent task', () {
      // Arrange
      final original = Task(id: '10', title: 'No change', completed: true);

      // Act
      final copy = original.copyWith();

      // Assert
      expect(copy.title, equals(original.title));
      expect(copy.completed, equals(original.completed));
      expect(copy.id, equals(original.id));
    });
  });

  group('Task Model — equality', () {
    test('two tasks with same id are equal', () {
      final t1 = Task(id: 'same', title: 'Title A');
      final t2 = Task(id: 'same', title: 'Title B');
      expect(t1, equals(t2));
    });

    test('two tasks with different ids are not equal', () {
      final t1 = Task(id: 'id-1', title: 'Title');
      final t2 = Task(id: 'id-2', title: 'Title');
      expect(t1, isNot(equals(t2)));
    });
  });
}