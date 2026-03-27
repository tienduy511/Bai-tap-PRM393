// Package: flutter/services.dart → rootBundle (đọc file trong assets/)
// Package: dart:convert          → jsonDecode
// Mục đích: Load JSON từ assets, parse, hiển thị ListView

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';   // rootBundle
import '../models/product.dart';

class Lab91AssetScreen extends StatefulWidget {
  const Lab91AssetScreen({super.key});
  @override
  State<Lab91AssetScreen> createState() => _Lab91AssetScreenState();
}

class _Lab91AssetScreenState extends State<Lab91AssetScreen> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFromAssets();
  }

  // Bước 3 & 4: Load + Decode JSON từ assets
  Future<void> _loadFromAssets() async {
    final String raw = await rootBundle.loadString('assets/data/products.json');
    final List<dynamic> jsonList = jsonDecode(raw);
    setState(() {
      _products = jsonList.map((e) => Product.fromJson(e)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 9.1 – Read JSON from Assets')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (ctx, i) {
          final p = _products[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${p.id}')),
            title: Text(p.name),
            // Hiển thị ít nhất 2 fields: name + price
            subtitle: Text('Giá: ${p.price.toStringAsFixed(0)} VNĐ'),
          );
        },
      ),
    );
  }
}