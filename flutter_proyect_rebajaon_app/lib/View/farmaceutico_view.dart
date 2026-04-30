import 'package:flutter/material.dart';

class HomeFarmaceuticoView extends StatelessWidget {
  const HomeFarmaceuticoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: const Center(
        child: Text(
          "Hola Farmacéutico",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}