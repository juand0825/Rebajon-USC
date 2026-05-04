import 'package:flutter/material.dart';

class MedicamentosView extends StatelessWidget {
  const MedicamentosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicamentos")),
      body: const Center(
        child: Text("Pantalla de medicamentos"),
      ),
    );
  }
}