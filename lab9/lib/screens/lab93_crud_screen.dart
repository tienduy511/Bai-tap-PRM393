// Package: ../services/storage_service.dart → auto-save sau mỗi thao tác
// Mục đích: Full CRUD (Add/Edit/Delete) + Search, auto-save JSON

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class Lab93CrudScreen extends StatefulWidget {
  const Lab93CrudScreen({super.key});
  @override
  State<Lab93CrudScreen> createState() => _Lab93CrudScreenState();
}

class _Lab93CrudScreenState extends State<Lab93CrudScreen> {
  final StorageService _storage = StorageService();
  List<Product> _all      = [];   // Toàn bộ dữ liệu
  List<Product> _filtered = [];   // Kết quả sau khi lọc
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _storage.loadProducts();
    setState(() {
      _all      = list;
      _filtered = list;
    });
  }

  // Auto-save + refresh filter
  Future<void> _autoSave() async {
    await _storage.saveProducts(_all);
    _applyFilter(_query);
  }

  void _applyFilter(String query) {
    setState(() {
      _query    = query;
      _filtered = _all
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // ── ADD ─────────────────────────────────────────────
  void _showAddDialog() {
    final nameCtrl  = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm sản phẩm'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl,  decoration: const InputDecoration(labelText: 'Tên')),
          TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá'),
              keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              final name  = nameCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text) ?? 0;
              if (name.isEmpty) return;
              _all.add(Product(
                id:    DateTime.now().millisecondsSinceEpoch,
                name:  name,
                price: price,
              ));
              _autoSave();
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  // ── EDIT ────────────────────────────────────────────
  void _showEditDialog(Product p) {
    final nameCtrl  = TextEditingController(text: p.name);
    final priceCtrl = TextEditingController(text: p.price.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa sản phẩm'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl,  decoration: const InputDecoration(labelText: 'Tên')),
          TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá'),
              keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              p.name  = nameCtrl.text.trim();
              p.price = double.tryParse(priceCtrl.text) ?? p.price;
              _autoSave();
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // ── DELETE ──────────────────────────────────────────
  void _deleteProduct(Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Xoá "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _all.remove(p);
              _autoSave();
              Navigator.pop(context);
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 9.3 – CRUD + Search')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: _applyFilter,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText:   'Tìm kiếm...',
                border:     OutlineInputBorder(),
              ),
            ),
          ),

          // Danh sách
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('Không có dữ liệu'))
                : ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final p = _filtered[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(p.name[0].toUpperCase()),
                  ),
                  title:    Text(p.name),
                  subtitle: Text('${p.price.toStringAsFixed(0)} VNĐ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:  const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showEditDialog(p),
                      ),
                      IconButton(
                        icon:  const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(p),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}