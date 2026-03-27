// Package: ../services/storage_service.dart → StorageService
// Mục đích: Thêm item, lưu/load từ file local, persist qua restart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class Lab92SaveLoadScreen extends StatefulWidget {
  const Lab92SaveLoadScreen({super.key});
  @override
  State<Lab92SaveLoadScreen> createState() => _Lab92SaveLoadScreenState();
}

class _Lab92SaveLoadScreenState extends State<Lab92SaveLoadScreen> {
  final StorageService _storage = StorageService();
  final TextEditingController _nameCtrl  = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Load ngay khi mở màn hình
  }

  // Bước 3: Load data lúc khởi động
  Future<void> _loadData() async {
    final list = await _storage.loadProducts();
    setState(() => _products = list);
  }

  // Bước 4: Thêm item vào list
  void _addItem() {
    final name  = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    if (name.isEmpty) return;

    setState(() {
      _products.add(Product(
        id:    DateTime.now().millisecondsSinceEpoch, // ID tự tăng
        name:  name,
        price: price,
      ));
    });
    _nameCtrl.clear();
    _priceCtrl.clear();
  }

  // Bước 5: Lưu file + hiện SnackBar
  Future<void> _save() async {
    await _storage.saveProducts(_products);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 9.2 – Save & Load JSON')),
      body: Column(
        children: [
          // Form thêm item
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giá'),
                )),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: _addItem,
                ),
              ],
            ),
          ),

          // Nút Save
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Lưu JSON'),
          ),

          const Divider(),

          // Danh sách
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (ctx, i) {
                final p = _products[i];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('${p.price.toStringAsFixed(0)} VNĐ'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}