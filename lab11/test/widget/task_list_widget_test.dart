// test/widget/task_list_widget_test.dart
//
// Widget tests for TaskListScreen.
// Key pattern with Riverpod: wrap pumpWidget in ProviderScope and override
// taskRepositoryProvider so each test gets a fresh, isolated repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/providers/task_providers.dart';
import 'package:taskly/repositories/task_repository.dart';
import 'package:taskly/screens/task_list_screen.dart';

/// Wraps [TaskListScreen] inside a [ProviderScope] that uses a fresh
/// [TaskRepository] so tests are fully isolated.
Widget buildTestApp({TaskRepository? repo}) {
  return ProviderScope(
    overrides: [
      taskRepositoryProvider.overrideWithValue(repo ?? TaskRepository()),
    ],
    child: const MaterialApp(home: TaskListScreen()),
  );
}

void main() {
  group('TaskListScreen — Widget Tests', () {
    // ── Empty State ─────────────────────────────────────────────────────────
    testWidgets('shows empty-state message when no tasks exist',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(buildTestApp());

          // Assert
          expect(find.text('No tasks yet. Add one!'), findsOneWidget);
          expect(find.byKey(const Key('taskList')), findsNothing);
        });

    // ── Add Task ────────────────────────────────────────────────────────────
    testWidgets('entering text and tapping Add shows task in list',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(buildTestApp());

          // Act
          await tester.enterText(find.byKey(const Key('taskInputField')), 'Buy milk');
          await tester.tap(find.byKey(const Key('addTaskButton')));
          await tester.pump();

          // Assert
          expect(find.text('Buy milk'), findsOneWidget);
          expect(find.text('No tasks yet. Add one!'), findsNothing);
        });

    testWidgets('text field is cleared after adding a task',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(buildTestApp());

          // Act
          await tester.enterText(find.byKey(const Key('taskInputField')), 'Some task');
          await tester.tap(find.byKey(const Key('addTaskButton')));
          await tester.pump();

          // Assert — input field is now empty
          final textField = tester.widget<TextField>(
            find.byKey(const Key('taskInputField')),
          );
          expect(textField.controller?.text, isEmpty);
        });

    testWidgets('empty input does NOT add a task', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestApp());

      // Act — tap Add without typing
      await tester.tap(find.byKey(const Key('addTaskButton')));
      await tester.pump();

      // Assert — still empty state
      expect(find.text('No tasks yet. Add one!'), findsOneWidget);
    });

    // ── Multiple Tasks ──────────────────────────────────────────────────────
    testWidgets('two tasks are both visible in the list',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(buildTestApp());

          // Act — add first task
          await tester.enterText(find.byKey(const Key('taskInputField')), 'Task Alpha');
          await tester.tap(find.byKey(const Key('addTaskButton')));
          await tester.pump();

          // Act — add second task
          await tester.enterText(find.byKey(const Key('taskInputField')), 'Task Beta');
          await tester.tap(find.byKey(const Key('addTaskButton')));
          await tester.pump();

          // Assert
          expect(find.text('Task Alpha'), findsOneWidget);
          expect(find.text('Task Beta'), findsOneWidget);
        });

    testWidgets('adding three tasks shows all three in list',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(buildTestApp());
          final titles = ['Task 1', 'Task 2', 'Task 3'];

          // Act
          for (final title in titles) {
            await tester.enterText(find.byKey(const Key('taskInputField')), title);
            await tester.tap(find.byKey(const Key('addTaskButton')));
            await tester.pump();
          }

          // Assert
          for (final title in titles) {
            expect(find.text(title), findsOneWidget);
          }
        });

    // ── Delete Task ─────────────────────────────────────────────────────────
    testWidgets('tapping delete icon removes task from list',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(buildTestApp());
          await tester.enterText(find.byKey(const Key('taskInputField')), 'Delete me');
          await tester.tap(find.byKey(const Key('addTaskButton')));
          await tester.pump();

          // Act
          await tester.tap(find.byIcon(Icons.delete));
          await tester.pump();

          // Assert
          expect(find.text('Delete me'), findsNothing);
          expect(find.text('No tasks yet. Add one!'), findsOneWidget);
        });
  });
}