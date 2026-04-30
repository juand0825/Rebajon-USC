import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/auth_controller.dart';
import 'login_view.dart';

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
            label: const Text("Cerrar sesion", style: TextStyle(color: Colors.red)),

          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Center(
        child: Text(
          "Bienvenido Administrador",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
