// Package: dart:io      → File, Directory
// Package: dart:convert → jsonEncode, jsonDecode
// Package: path_provider (pub.dev) → getApplicationDocumentsDirectory()
// Mục đích: Tách biệt logic lưu trữ khỏi UI

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

class StorageService {
  static const String _fileName = 'products_local.json';

  // Lấy đường dẫn file trong bộ nhớ máy
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // Đọc danh sách sản phẩm từ file local
  Future<List<Product>> loadProducts() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return []; // File chưa tồn tại → trả về rỗng

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Ghi danh sách sản phẩm vào file local
  Future<void> saveProducts(List<Product> products) async {
    final file = await _getFile();
    final jsonString = jsonEncode(products.map((p) => p.toJson()).toList());
    await file.writeAsString(jsonString);
  }
}