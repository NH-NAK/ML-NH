import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/dashboard_screen.dart';

void main() {
  runApp(const OnyxModApp());
}

class OnyxModApp extends StatelessWidget {
  const OnyxModApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.dark();
    return MaterialApp(
      title: 'NH-SKIN',
      debugShowCheckedModeBanner: false,
      theme: darkTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFCC),
          secondary: Color(0xFF9400D3),
          surface: Color(0xFF1E1E24),
        ),
        textTheme: GoogleFonts.battambangTextTheme(darkTheme.textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

