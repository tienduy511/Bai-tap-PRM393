// lib/services/image_service.dart
// Exercise 12.2 — Precache ảnh để tránh jank khi render lần đầu
//
// precacheImage() tải ảnh vào ImageCache trước khi widget cần render
// Gọi trong initState() của root widget để ảnh sẵn sàng từ đầu

import 'package:flutter/material.dart';

class ImageService {
  /// Danh sách đường dẫn asset cần precache
  /// Chỉ khai báo ảnh thường xuyên xuất hiện — không precache tất cả
  static const List<String> _assetPaths = [
    'assets/icon_128.png',
    // Thêm ảnh hay dùng vào đây
  ];

  /// Gọi sau frame đầu tiên render xong để không block UI
  /// Ví dụ: WidgetsBinding.instance.addPostFrameCallback((_) {
  ///          ImageService.precacheImages(context);
  ///        });
  static Future<void> precacheImages(BuildContext context) async {
    for (final path in _assetPaths) {
      // Mỗi ảnh được tải vào ImageCache — lần sau render ngay lập tức
      await precacheImage(AssetImage(path), context);
    }
  }
}
