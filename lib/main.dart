import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/auth_session.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_data_builder_screen.dart';
import 'screens/super_admin_screen.dart';
import 'services/auth_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = await AuthStorage.load();

  runApp(CampusCoreApp(session: session));
}

class CampusCoreApp extends StatefulWidget {
  const CampusCoreApp({super.key, this.session});

  final AuthSession? session;

  @override
  State<CampusCoreApp> createState() => _CampusCoreAppState();
}

class _CampusCoreAppState extends State<CampusCoreApp> {
  bool dark = false;

  String get initialRoute {
    final session = widget.session;
    if (session == null || session.accessToken.isEmpty) {
      return '/login';
    }

    return session.role == 'superadmin'
        ? '/super-admin'
        : session.role == 'admin'
            ? '/admin-data'
            : '/home';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusCore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E1B4B),
          brightness: dark ? Brightness.dark : Brightness.light,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor:
            dark ? const Color(0xFF0A0A0F) : const Color(0xFFF8FAFC),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (c) => const LoginScreen(),
        '/home': (c) => const HomeScreen(),
        '/admin-data': (c) => const AdminDataBuilderScreen(),
        '/super-admin': (c) => const SuperAdminScreen(),
      },
    );
  }
}
