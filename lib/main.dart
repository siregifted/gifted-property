import 'package:flutter/material.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const GiftedPropertyApp());
}

class GiftedPropertyApp extends StatelessWidget {
  const GiftedPropertyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gifted Property',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B1F33)),
      ),
      home: const HomePage(),
    );
  }
}
