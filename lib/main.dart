import 'package:flutter/material.dart';

import 'vn/edu/fpt/app_colors.dart';
import 'vn/edu/fpt/view/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FPT Schools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: FptColors.orange,
        ).copyWith(primary: FptColors.orange, onPrimary: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          // Neutral grey resting fields → clean on a white background.
          fillColor: const Color(0xFFF3F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          // Brand-orange ring only when the field is focused.
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: FptColors.orange, width: 1.6),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
