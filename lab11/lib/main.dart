// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(
    // ProviderScope is REQUIRED — it is the root of the Riverpod tree
    const ProviderScope(
      child: TasklyApp(),
    ),
  );
}

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}