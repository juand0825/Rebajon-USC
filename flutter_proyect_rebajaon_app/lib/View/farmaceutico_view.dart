import 'package:flutter/material.dart';
import 'medicamentos_view.dart';
import 'ventas_view.dart';
import 'inventario_view.dart';
import 'alertas_view.dart';
import 'reportes_view.dart';

class HomeFarmaceuticoView extends StatelessWidget {
  const HomeFarmaceuticoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Panel Farmacéutico"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(
              context,
              titulo: "Medicamentos",
              icono: Icons.medication,
              destino: const MedicamentosView(),
            ),
            _buildCard(
              context,
              titulo: "Ventas",
              icono: Icons.shopping_cart,
              destino: const VentasView(),
            ),
            _buildCard(
              context,
              titulo: "Inventario",
              icono: Icons.inventory,
              destino: const InventarioView(),
            ),
            _buildCard(
              context,
              titulo: "Alertas",
              icono: Icons.warning,
              destino: const AlertasView(),
            ),
            _buildCard(
              context,
              titulo: "Reportes",
              icono: Icons.bar_chart,
              destino: const ReportesView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String titulo,
    required IconData icono,
    required Widget destino,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destino),
        );
      },
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 50, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
