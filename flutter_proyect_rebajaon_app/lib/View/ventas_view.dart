import 'package:flutter/material.dart';

class VentasView extends StatelessWidget{
  const VentasView({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ventas")),
      body: const Center(
        child: Text("Pantalla de ventas"),
      ),
    );
  }
}