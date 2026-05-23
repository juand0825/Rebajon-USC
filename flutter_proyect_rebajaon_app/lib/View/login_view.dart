import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/auth_controller.dart';
import '../Temas/Estilos.dart';
import 'farmaceutico_view.dart';
import 'administrador.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _documentoCtrl = TextEditingController();
  final _claveCtrl     = TextEditingController();
  bool _verClave       = false;

  @override
  void dispose() {
    _documentoCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    final auth  = context.read<AuthController>();
    final exito = await auth.login(
      _documentoCtrl.text.trim(),
      _claveCtrl.text,
    );

    if (exito && mounted) {
      if (auth.rolActual == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeAdminView()),
        );
      } else if (auth.rolActual == 'farmaceutico') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFarmaceuticoView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 0,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.inputBorder, width: 0.5),
            ),
            child: SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ── PLACEHOLDER LOGO ──────────────────────────
                    // Cuando tengas el logo reemplazá esto por:
                    // Image.asset('assets/images/logo.png', height: 80, fit: BoxFit.contain)
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              color: AppColors.primaryLight, size: 28),
                          SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Logo El Rebajón USC",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "assets/images/logo.png",
                                style: TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Bienvenido",
                      style: AppTextos.headline,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Inicia sesión para continuar",
                      style: AppTextos.apagado,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    TextField(
                      controller: _documentoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Número de documento",
                        prefixIcon: Icon(Icons.badge_outlined,
                            color: AppColors.primaryLight, size: 20),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: _claveCtrl,
                      obscureText: !_verClave,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.primaryLight, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _verClave
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _verClave = !_verClave),
                        ),
                      ),
                    ),

                    if (auth.error != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.errorTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: auth.cargando ? null : _ingresar,
                        child: auth.cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text("Ingresar"),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}