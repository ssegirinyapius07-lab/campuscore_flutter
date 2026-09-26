import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String role = 'Student';
  final regCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isFirstLogin = false;
  bool loading = false;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  void dispose() {
    regCtrl.dispose();
    passCtrl.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (regCtrl.text.trim().isEmpty || passCtrl.text.isEmpty) {
      _showMessage('Enter your identifier and password.');
      return;
    }
    setState(() => loading = true);
    try {
      final session = await _authService.login(
        identifier: regCtrl.text,
        password: passCtrl.text,
      );
      await AuthStorage.save(session);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        session.role == 'admin' ? '/admin-data' : '/home',
      );
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('Could not connect to CampusCore. Check the server and network.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF1E1B4B), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)))),
              const SizedBox(height: 24),
              const Text('Welcome to CampusCore', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('Your Academic Success Hub', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 24),
              // Role pills
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['Student','Lecturer','Admin','Parent'].map((r) {
                final selected = role==r;
                return Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(r), selected: selected, onSelected: (_) => setState(()=>role=r), selectedColor: const Color(0xFF1E1B4B), labelStyle: TextStyle(color: selected?Colors.white:Colors.black54)));
              }).toList())),
              const SizedBox(height: 24),
              TextField(controller: regCtrl, decoration: InputDecoration(labelText: role == 'Student' ? 'Registration number or email' : 'Staff ID or email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
              const SizedBox(height: 16),
              TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1B4B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: loading ? null : _login, child: loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              const SizedBox(height: 16),
              const Center(child: Text('End-to-end encrypted • Zero tracking', style: TextStyle(fontSize: 11, color: Colors.black38))),
            ],
          ),
        ),
      ),
    );
  }

