import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_data_builder_screen.dart';

void main() {
  runApp(const CampusCoreApp());
}

class CampusCoreApp extends StatefulWidget {
  const CampusCoreApp({super.key});
  @override
  State<CampusCoreApp> createState() => _CampusCoreAppState();
}

class _CampusCoreAppState extends State<CampusCoreApp> {
  bool dark = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusCore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E1B4B), brightness: dark ? Brightness.dark : Brightness.light),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor: dark ? const Color(0xFF0A0A0F) : const Color(0xFFF8FAFC),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (c) => const LoginScreen(),
        '/home': (c) => const HomeScreen(),
        '/admin-data': (c) => const AdminDataBuilderScreen(),
      },
    );
  }
}
