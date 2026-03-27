import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import 'lab3_login_screen.dart';

class Lab3HomeScreen extends StatelessWidget {
  final String username;
  const Lab3HomeScreen({super.key, required this.username});

  Future<void> _logout(BuildContext context) async {
    await SessionService().clearSession();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Lab3LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10.3 – Home'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user,
                color: Colors.teal, size: 80),
            const SizedBox(height: 16),
            Text('Xin chào, $username!',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Token được lưu – Auto login hoạt động!'),
            const SizedBox(height: 8),
            const Text('Bấm logout để xoá session.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}