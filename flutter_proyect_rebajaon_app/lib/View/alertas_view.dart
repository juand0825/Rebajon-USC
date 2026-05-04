import 'package:flutter/material.dart';

class AlertasView extends StatelessWidget {
  const AlertasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alertas")),
      body: const Center(
        child: Text("Pantalla de alertas"),
      ),
    );
  }
}