import 'package:fantasy_colegas_app/presentation/auth/auth_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Fantasy Colegas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBC1028)),
        useMaterial3: true,
        textTheme: GoogleFonts.exoTextTheme(textTheme).copyWith(
          bodyMedium: GoogleFonts.exo(textStyle: textTheme.bodyMedium, color: Colors.white),
          displayLarge: GoogleFonts.exo(textStyle: textTheme.displayLarge, fontWeight: FontWeight.bold),
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}