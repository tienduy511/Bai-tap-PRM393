// lib/widgets/empty_state_widget.dart
// Exercise 12.4 — Widget hoàn toàn const, không bao giờ rebuild

import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Toàn bộ widget tree là const → Flutter reuse, không tạo lại bao giờ
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chưa có task nào!',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Nhấn + để thêm task mới.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
