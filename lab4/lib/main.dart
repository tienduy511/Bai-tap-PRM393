import 'package:flutter/material.dart';
import 'exercise1_core_widgets.dart';
import 'exercise2_input_controls.dart';
import 'exercise3_layout.dart';
import 'exercise4_app_structure.dart';
import 'exercise5_common_fixes.dart';

void main() {
  runApp(const Lab4App());
}

/// Root app widget – shows a home menu to navigate to each exercise.
class Lab4App extends StatelessWidget {
  const Lab4App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 4 – Flutter UI Fundamentals',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeMenu(),
    );
  }
}

/// Simple home screen with buttons that navigate to each exercise.
class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  // List of exercise titles and their destination widgets.
  static const List<Map<String, dynamic>> exercises = [
    {'title': 'Exercise 1 – Core Widgets Demo', 'widget': CoreWidgetsDemo()},
    {'title': 'Exercise 2 – Input Controls Demo', 'widget': InputControlsDemo()},
    {'title': 'Exercise 3 – Layout Demo', 'widget': LayoutDemo()},
    {'title': 'Exercise 4 – App Structure & Theme', 'widget': AppStructureDemo()},
    {'title': 'Exercise 5 – Common UI Fixes', 'widget': CommonUIFixes()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 4 – Flutter UI Fundamentals'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(exercise['title'] as String),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => exercise['widget'] as Widget,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}