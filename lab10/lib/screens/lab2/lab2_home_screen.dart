import 'package:flutter/material.dart';

class Lab2HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const Lab2HomeScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 10.2 – Home')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(userData['image'] ?? ''),
                radius: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Xin chào, ${userData['firstName']} ${userData['lastName']}!',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Email: ${userData['email']}'),
            const SizedBox(height: 4),
            Text(
              'Token: ${(userData['accessToken'] as String).substring(0, 20)}...',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}