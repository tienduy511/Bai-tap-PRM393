// lib/main.dart
// Exercise 12.4 — Entry point tối ưu cho release build
//
// Checklist release:
//   ✅ debugShowCheckedModeBanner: false
//   ✅ MultiProvider setup
//   ✅ Precache ảnh sau frame đầu
//   ✅ Không có print() — dùng PerformanceUtils.log()

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/task_list_screen.dart';
import 'services/image_service.dart';
import 'utils/performance_utils.dart';

void main() {
  PerformanceUtils.log('App khởi động');
  runApp(const TasklyApp());
}

class TasklyApp extends StatefulWidget {
  const TasklyApp({super.key});

  @override
  State<TasklyApp> createState() => _TasklyAppState();
}

class _TasklyAppState extends State<TasklyApp> {
  @override
  void initState() {
    super.initState();
    // Exercise 12.2: Precache ảnh sau frame đầu tiên render xong
    // addPostFrameCallback đảm bảo context hợp lệ trước khi precache
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ImageService.precacheImages(context);
        PerformanceUtils.log('Precache ảnh hoàn thành');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Exercise 12.1: ChangeNotifierProvider cho TaskProvider
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Taskly',
        // Exercise 12.4: tắt debug banner khi submit release
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const TaskListScreen(),
      ),
    );
  }
}
