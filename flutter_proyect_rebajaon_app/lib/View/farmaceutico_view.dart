import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Controllers/auth_controller.dart';
import 'login_view.dart';
import 'medicamentos_view.dart';
import 'ventas_view.dart';
import 'inventario_view.dart';
import 'alertas_view.dart';
import 'reportes_view.dart';

class HomeFarmaceuticoView extends StatelessWidget {
  const HomeFarmaceuticoView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,

        // INFORMACIÓN DEL USUARIO QUE INICIÓ SESIÓN
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                auth.emailActual != null
                    ? auth.emailActual![0].toUpperCase()
                    : 'F',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                auth.emailActual ?? "Farmacéutico",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),

        // BOTÓN CERRAR SESIÓN
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.red,
            tooltip: "Cerrar sesión",
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Cerrar sesión"),
                  content: const Text(
                    "¿Estás seguro de que deseas cerrar sesión?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text("Cerrar sesión"),
                    ),
                  ],
                ),
              );

              if (confirmar == true && context.mounted) {
                auth.cerrarSesion();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
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
        Navigator.push(context, MaterialPageRoute(builder: (_) => destino));
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
