// test/widget/task_navigation_test.dart
//
// Navigation tests: TaskListScreen → TaskDetailScreen.
// Seeds the repository provider with a pre-populated TaskRepository
// so navigation can be triggered immediately without going through the UI.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/providers/task_providers.dart';
import 'package:taskly/repositories/task_repository.dart';
import 'package:taskly/screens/task_list_screen.dart';

/// Builds a test app with a pre-seeded [TaskRepository].
Widget buildSeededApp(List<Task> tasks) {
  final repo = TaskRepository(initialTasks: tasks);
  return ProviderScope(
    overrides: [
      taskRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: TaskListScreen()),
  );
}

void main() {
  group('Navigation — TaskListScreen → TaskDetailScreen', () {
    testWidgets('tapping task navigates to TaskDetailScreen (AppBar = "Task Detail")',
            (WidgetTester tester) async {
          // Arrange — seed one task
          await tester.pumpWidget(buildSeededApp([
            const Task(id: 'nav-1', title: 'My Seeded Task'),
          ]));

          // Task must appear in list
          expect(find.text('My Seeded Task'), findsOneWidget);

          // Act — tap the task
          await tester.tap(find.text('My Seeded Task'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('Task Detail'), findsOneWidget);
        });

    testWidgets('TaskDetailScreen contains detailTitleField after navigation',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(buildSeededApp([
            const Task(id: 'nav-2', title: 'Navigate to me'),
          ]));

          // Act
          await tester.tap(find.text('Navigate to me'));
          await tester.pumpAndSettle();

          // Assert
          expect(find.byKey(const Key('detailTitleField')), findsOneWidget);
        });

    testWidgets('detailTitleField is pre-filled with the task title',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(buildSeededApp([
            const Task(id: 'nav-3', title: 'Pre-filled Title'),
          ]));

          // Act
          await tester.tap(find.text('Pre-filled Title'));
          await tester.pumpAndSettle();

          // Assert
          final textField = tester.widget<TextField>(
            find.byKey(const Key('detailTitleField')),
          );
          expect(textField.controller?.text, equals('Pre-filled Title'));
        });

    testWidgets('pressing back returns to TaskListScreen',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(buildSeededApp([
            const Task(id: 'nav-4', title: 'Back test task'),
          ]));

          // Act — navigate to detail
          await tester.tap(find.text('Back test task'));
          await tester.pumpAndSettle();

          // Act — press back
          await tester.pageBack();
          await tester.pumpAndSettle();

          // Assert — back on list
          expect(find.text('Taskly'), findsOneWidget);
          expect(find.text('Task Detail'), findsNothing);
        });

    testWidgets('seeded task is visible and tappable without adding via UI',
            (WidgetTester tester) async {
          // Arrange — seed 2 tasks
          await tester.pumpWidget(buildSeededApp([
            const Task(id: 's1', title: 'Seed Alpha'),
            const Task(id: 's2', title: 'Seed Beta'),
          ]));

          // Assert — both visible immediately
          expect(find.text('Seed Alpha'), findsOneWidget);
          expect(find.text('Seed Beta'), findsOneWidget);

          // Act — navigate from second task
          await tester.tap(find.text('Seed Beta'));
          await tester.pumpAndSettle();

          expect(find.text('Task Detail'), findsOneWidget);
        });
  });
}