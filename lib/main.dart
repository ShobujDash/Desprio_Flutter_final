import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16834B);
    const yellow = Color(0xFFFFC928);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'দেশপ্রিয়',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green).copyWith(
          primary: green,
          secondary: yellow,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFDF6),
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: const HomeScreen(),
    );
  }
}
