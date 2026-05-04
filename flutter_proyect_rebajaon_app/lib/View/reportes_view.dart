import 'package:flutter/material.dart';

class ReportesView  extends StatelessWidget {
  const ReportesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reportes")),
      body: const Center(
        child: Text("Pantalla de reportes"),
      ),
    );
  }
}