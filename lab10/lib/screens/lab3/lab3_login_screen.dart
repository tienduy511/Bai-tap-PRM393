import 'package:flutter/material.dart';
import '../../services/api_auth_service.dart';
import '../../services/session_service.dart';
import 'lab3_home_screen.dart';

class Lab3LoginScreen extends StatefulWidget {
  const Lab3LoginScreen({super.key});

  @override
  State<Lab3LoginScreen> createState() => _State();
}

class _State extends State<Lab3LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _apiService = ApiAuthService();
  final _session = SessionService();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final data = await _apiService.login(
          _userCtrl.text.trim(), _passCtrl.text);

      await _session.saveSession(
        data['accessToken'],
        '${data['firstName']} ${data['lastName']}',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Lab3HomeScreen(
            username: '${data['firstName']} ${data['lastName']}',
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose(); _passCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 10.3 – Auto Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Nhập username' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Nhập mật khẩu' : null,
              ),
              const SizedBox(height: 8),
              const Text('Test: emilys / emilyspass',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              if (_error != null) _ErrorBox(message: _error!),
              const SizedBox(height: 16),
              _LoginButton(loading: _loading, onTap: _login),
            ],
          ),
        ),
      ),
    );
  }
}