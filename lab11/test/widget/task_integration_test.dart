// test/widget/task_integration_test.dart
//
// Integration tests: full end-to-end user flows.
//
// Flow tested:
//   1. Add "Original title" via UI
//   2. Tap task → navigate to TaskDetailScreen
//   3. Edit title → "Updated title"
//   4. Tap Save → pop back to list
//   5. Verify "Updated title" visible, "Original title" gone

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/providers/task_providers.dart';
import 'package:taskly/repositories/task_repository.dart';
import 'package:taskly/screens/task_list_screen.dart';

Widget buildTestApp({TaskRepository? repo}) {
  return ProviderScope(
    overrides: [
      taskRepositoryProvider.overrideWithValue(repo ?? TaskRepository()),
    ],
    child: const MaterialApp(home: TaskListScreen()),
  );
}

void main() {
  group('Integration — Full Add → Navigate → Edit → Save', () {
    testWidgets(
      'add task, edit title in detail screen, verify updated title in list',
          (WidgetTester tester) async {
        // ── ARRANGE ──────────────────────────────────────────────
        await tester.pumpWidget(buildTestApp());

        // ── ACT 1: Add "Original title" ──────────────────────────
        await tester.enterText(
          find.byKey(const Key('taskInputField')),
          'Original title',
        );
        await tester.tap(find.byKey(const Key('addTaskButton')));
        await tester.pump();

        // ASSERT — task in list
        expect(find.text('Original title'), findsOneWidget);

        // ── ACT 2: Tap task → open detail ────────────────────────
        await tester.tap(find.text('Original title'));
        await tester.pumpAndSettle();

        expect(find.text('Task Detail'), findsOneWidget);
        expect(find.byKey(const Key('detailTitleField')), findsOneWidget);

        // ── ACT 3: Clear field and type new title ─────────────────
        await tester.enterText(
          find.byKey(const Key('detailTitleField')),
          'Updated title',
        );

        // ── ACT 4: Save ───────────────────────────────────────────
        await tester.tap(find.byKey(const Key('saveButton')));
        await tester.pumpAndSettle();

        // ── ASSERT: list shows updated title ─────────────────────
        expect(find.text('Updated title'), findsOneWidget);
        expect(find.text('Original title'), findsNothing);
      },
    );

    testWidgets(
      'navigating back WITHOUT saving preserves original title',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());

        await tester.enterText(
          find.byKey(const Key('taskInputField')),
          'Unchanged title',
        );
        await tester.tap(find.byKey(const Key('addTaskButton')));
        await tester.pump();

        // Navigate to detail
        await tester.tap(find.text('Unchanged title'));
        await tester.pumpAndSettle();

        // Edit but press back without saving
        await tester.enterText(
          find.byKey(const Key('detailTitleField')),
          'Discarded change',
        );
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Unchanged title'), findsOneWidget);
        expect(find.text('Discarded change'), findsNothing);
      },
    );

    testWidgets(
      'seeded task can be updated via full edit flow',
          (WidgetTester tester) async {
        // Arrange — seed from repository directly (bypasses UI add step)
        final repo = TaskRepository(
          initialTasks: [const Task(id: 'seed-1', title: 'Seeded Task')],
        );
        await tester.pumpWidget(buildTestApp(repo: repo));

        expect(find.text('Seeded Task'), findsOneWidget);

        // Act — navigate to detail
        await tester.tap(find.text('Seeded Task'));
        await tester.pumpAndSettle();

        // Edit title
        await tester.enterText(
          find.byKey(const Key('detailTitleField')),
          'Seeded Task — Edited',
        );
        await tester.tap(find.byKey(const Key('saveButton')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Seeded Task — Edited'), findsOneWidget);
        expect(find.text('Seeded Task'), findsNothing);
      },
    );

    testWidgets(
      'multiple tasks — only edited task title changes',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestApp());

        for (final title in ['Task One', 'Task Two']) {
          await tester.enterText(
            find.byKey(const Key('taskInputField')),
            title,
          );
          await tester.tap(find.byKey(const Key('addTaskButton')));
          await tester.pump();
        }

        // Act — edit only "Task Two"
        await tester.tap(find.text('Task Two'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('detailTitleField')),
          'Task Two — Updated',
        );
        await tester.tap(find.byKey(const Key('saveButton')));
        await tester.pumpAndSettle();

        // Assert — Task One unchanged, Task Two updated
        expect(find.text('Task One'), findsOneWidget);
        expect(find.text('Task Two — Updated'), findsOneWidget);
        expect(find.text('Task Two'), findsNothing);
      },
    );
  });
}