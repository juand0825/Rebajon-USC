import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Controllers/auth_controller.dart';
import '../Temas/Estilos.dart';
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

    final nombreUsuario = auth.emailActual
            ?.split('@')
            .first
            .replaceAll(RegExp(r'[0-9]'), '') ??
        'Regente';

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,

        title: Row(
          children: [
            // Placeholder logo — reemplazá por Image.asset cuando lo tengas
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medication_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "El Rebajón USC",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    auth.emailActual ?? "Farmacéutico",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB8D4F0),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        actions: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondary,
            child: Text(
              auth.emailActual != null
                  ? auth.emailActual![0].toUpperCase()
                  : 'F',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xFFFFB3B3)),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    "Cerrar sesión",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  content: const Text(
                    "¿Estás seguro de que deseas cerrar sesión?",
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── BANNER BIENVENIDA ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bienvenido, $nombreUsuario",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Regencia de Farmacia · El Rebajón USC",
                          style: TextStyle(
                            color: Color(0xFFB8D4F0),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Farmacéutico",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text("Módulos", style: AppTextos.titulo),

            const SizedBox(height: 12),

            // ── GRID DE MÓDULOS ───────────────────────────────────
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 440,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
                children: [
                  _buildCard(
                    context,
                    titulo: "Medicamentos",
                    subtitulo: "Registro y consulta",
                    icono: Icons.medication_outlined,
                    color: AppColors.primary,
                    destino: const MedicamentosView(),
                  ),
                  _buildCard(
                    context,
                    titulo: "Ventas",
                    subtitulo: "Dispensación",
                    icono: Icons.shopping_cart_outlined,
                    color: AppColors.secondary,
                    destino: const VentasView(),
                  ),
                  _buildCard(
                    context,
                    titulo: "Inventario",
                    subtitulo: "Stock actual",
                    icono: Icons.inventory_2_outlined,
                    color: AppColors.primaryLight,
                    destino: const InventarioView(),
                  ),
                  _buildCard(
                    context,
                    titulo: "Alertas",
                    subtitulo: "Vencimientos",
                    icono: Icons.warning_amber_outlined,
                    color: AppColors.warning,
                    destino: const AlertasView(),
                  ),
                  _buildCard(
                    context,
                    titulo: "Reportes",
                    subtitulo: "Estadísticas",
                    icono: Icons.bar_chart_outlined,
                    color: AppColors.secondaryDark,
                    destino: const ReportesView(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color color,
    required Widget destino,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destino),
      ),
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.inputBorder, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icono, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}