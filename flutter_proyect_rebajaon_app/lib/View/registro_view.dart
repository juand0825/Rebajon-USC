import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/auth_controller.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _emailCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _numIdentificacionCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  String _rolSeleccionado = 'farmaceutico';
  bool _verClave = false;

  static const String _codigoFarma = "110537";
  static const String _codigoAdmin = "944157";

  @override
  void dispose() {
    _emailCtrl.dispose();
    _claveCtrl.dispose();
    _numIdentificacionCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.registrado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registro exitoso")));
        auth.resetRegistrado();
        Navigator.pop(context);
      });
    }

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
                    "Crear cuenta",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Correo electrónico",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _claveCtrl,
                    obscureText: !_verClave,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verClave ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _verClave = !_verClave),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _numIdentificacionCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: "Número de identificación",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _rolSeleccionado,
                    decoration: const InputDecoration(
                      labelText: "Rol",
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'farmaceutico',
                        child: Text("Farmacéutico"),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text("Administrador"),
                      ),
                    ],

                    onChanged: (valor) =>
                        setState(() => _rolSeleccionado = valor!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codigoCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Código de acceso",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 8),
                  if (auth.error != null)
                    Text(
                      auth.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.cargando
                          ? null
                          : () {
                              if (_emailCtrl.text.isEmpty ||
                                  _claveCtrl.text.isEmpty ||
                                  _numIdentificacionCtrl.text.isEmpty ||
                                  _codigoCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Por favor completa todos los campos",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final codigoValido =
                                  (_rolSeleccionado == 'farmaceutico' &&
                                      _codigoCtrl.text == _codigoFarma) ||
                                  (_rolSeleccionado == 'admin' &&
                                      _codigoCtrl.text == _codigoAdmin);

                              if (!codigoValido) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Código de acceso incorrecto",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              auth.register(
                                _emailCtrl.text.trim(),
                                _claveCtrl.text,
                                _numIdentificacionCtrl.text,
                                _rolSeleccionado,
                              );
                            },
                      child: auth.cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Registrar"),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Volver al login"),
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
