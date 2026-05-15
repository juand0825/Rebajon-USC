import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/auth_controller.dart';
import 'login_view.dart';
import 'registro_view.dart';
import 'inventario_view.dart';
import 'alertas_view.dart';

class HomeAdminView extends StatelessWidget {
  const HomeAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                auth.emailActual != null
                    ? auth.emailActual![0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              auth.emailActual ?? "Administrador",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              auth.cerrarSesion();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Colors.red),
            ),
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
              titulo: "Registrar usuarios",
              icono: Icons.person_add,
              destino: const RegistroView(),
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
