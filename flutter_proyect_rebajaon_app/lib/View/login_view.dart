import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/auth_controller.dart';
import 'farmaceutico_view.dart';
import 'administrador.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _documentoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  bool _verClave = false;

  @override
  void dispose() {
    _documentoCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    final auth = context.read<AuthController>();

    final exito = await auth.login(_documentoCtrl.text.trim(), _claveCtrl.text);

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 380,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Bienvenido",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Inicia sesión para continuar",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // CAMPO NÚMERO DE DOCUMENTO
                  TextField(
                    controller: _documentoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Número de documento",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CAMPO CONTRASEÑA
                  TextField(
                    controller: _claveCtrl,
                    obscureText: !_verClave,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verClave ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _verClave = !_verClave;
                          });
                        },
                      ),
                    ),
                  ),

                  // MENSAJE DE ERROR
                  if (auth.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      auth.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // BOTÓN INGRESAR
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.cargando ? null : _ingresar,
                      child: auth.cargando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text("Ingresar"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
