import 'package:flutter/material.dart';
import '../../services/mock_auth_service.dart';
import 'lab1_home_screen.dart';

class Lab1LoginScreen extends StatefulWidget {
  const Lab1LoginScreen({super.key});

  @override
  State<Lab1LoginScreen> createState() => _State();
}

class _State extends State<Lab1LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _service = MockAuthService();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final token = await _service.login(
        _emailCtrl.text.trim(), _passCtrl.text);

    setState(() => _loading = false);

    if (token != null) {
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const Lab1HomeScreen()));
    } else {
      setState(() => _error = 'Email hoặc mật khẩu không đúng');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 10.1 – Mock Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập email';
                  if (!v.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập mật khẩu';
                  if (v.length < 6) return 'Tối thiểu 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text('Test: test@example.com / 123456',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              if (_error != null)
                _ErrorBox(message: _error!),
              const SizedBox(height: 16),
              _LoginButton(loading: _loading, onTap: _login),
            ],
          ),
        ),
      ),
    );
  }
}