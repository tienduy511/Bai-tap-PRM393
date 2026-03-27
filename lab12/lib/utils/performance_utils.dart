// lib/utils/performance_utils.dart
// Exercise 12.4 — Thay thế print() bằng log có điều kiện
//
// Vấn đề với print():
//   - Vẫn chạy trong release build → tốn CPU
//   - Không có tag → khó lọc log
//   - Không có timestamp
//
// Giải pháp: kDebugMode đảm bảo log bị tree-shaken hoàn toàn trong release

import 'package:flutter/foundation.dart';

class PerformanceUtils {
  // Private constructor — class này chỉ có static methods
  PerformanceUtils._();

  /// Thay thế print() — chỉ in ở debug mode
  /// Trong release build, toàn bộ block if(kDebugMode) bị tree-shaken
  static void log(String message, {String tag = 'Taskly'}) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  /// Log warning
  static void warn(String message) {
    if (kDebugMode) {
      debugPrint('[Taskly ⚠️] $message');
    }
  }

  /// Đo thời gian thực thi một function — chỉ hoạt động ở debug mode
  static Future<T> measureTime<T>(
      String label,
      Future<T> Function() fn,
      ) async {
    if (!kDebugMode) return fn();
    final stopwatch = Stopwatch()..start();
    final result = await fn();
    stopwatch.stop();
    debugPrint('[Taskly ⏱] $label: ${stopwatch.elapsedMilliseconds}ms');
    return result;
  }
}
