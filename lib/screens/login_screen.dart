import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String role = 'Student';
  final regCtrl = TextEditingController(text: 'BACS/M/25D/UG/001');
  final passCtrl = TextEditingController();
  bool isFirstLogin = false;

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
              TextField(controller: regCtrl, decoration: InputDecoration(labelText: role=='Student' ? 'Registration No e.g. BACS/M/25D/UG/001' : 'Staff ID', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
              const SizedBox(height: 16),
              TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: const Color(0xFFF8FAFC))),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1B4B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () {
                if (isFirstLogin || regCtrl.text==passCtrl.text) {
                  _showForceChange();
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              }, child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              const SizedBox(height: 16),
              const Center(child: Text('End-to-end encrypted • Zero tracking', style: TextStyle(fontSize: 11, color: Colors.black38))),
            ],
          ),
        ),
      ),
    );
  }

  void _showForceChange() {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      title: const Text('Change Default Password'),
      content: const Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Your default password is your registration number. Please change it before proceeding.', style: TextStyle(fontSize: 13)),
        SizedBox(height: 12),
        TextField(decoration: InputDecoration(labelText: 'New Password', border: OutlineInputBorder()), obscureText: true),
        SizedBox(height: 12),
        TextField(decoration: InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()), obscureText: true),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), child: const Text('Update & Continue'))],
    ));
  }
}
