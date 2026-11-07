
import 'package:game/screen/home_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const Imagica());
}

class Imagica extends StatelessWidget {
  const Imagica({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Imagica',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}
