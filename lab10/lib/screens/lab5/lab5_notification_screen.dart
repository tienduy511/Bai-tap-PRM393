import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class Lab5NotificationScreen extends StatelessWidget {
  const Lab5NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 10.5 – Notification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active,
                  size: 80, color: Colors.orange),
              const SizedBox(height: 32),
              _NotifButton(
                label: 'Gửi thông báo ngay',
                icon: Icons.send,
                color: Colors.indigo,
                onTap: () async {
                  await NotificationService().showNotification(
                    id: 10,
                    title: '🎉 Thông báo!',
                    body: 'Local notification từ Lab 10.5',
                  );
                },
              ),
              const SizedBox(height: 16),
              _NotifButton(
                label: 'Giả lập Login → Notification',
                icon: Icons.login,
                color: Colors.green,
                onTap: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  await NotificationService().showNotification(
                    id: 11,
                    title: '✅ Đăng nhập thành công!',
                    body: 'Chào mừng bạn trở lại 👋',
                  );
                },
              ),
              const SizedBox(height: 16),
              _NotifButton(
                label: 'Xoá tất cả thông báo',
                icon: Icons.clear_all,
                color: Colors.red,
                onTap: () async {
                  await NotificationService().cancelAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Đã xoá tất cả thông báo')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NotifButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
      ),
    );
  }
}