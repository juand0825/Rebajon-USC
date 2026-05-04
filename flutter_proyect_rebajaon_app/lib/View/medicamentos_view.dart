import 'package:flutter/material.dart';

class MedicamentosView extends StatefulWidget {
  const MedicamentosView({super.key});

  @override
  State<MedicamentosView> createState() => _MedicamentosViewState();
}

class _MedicamentosViewState extends State<MedicamentosView> {
  final nombreCtrl = TextEditingController();
  final principioCtrl = TextEditingController();
  final presentacionCtrl = TextEditingController();
  final fabricanteCtrl = TextEditingController();
  final stockMinimoCtrl = TextEditingController();

  final loteCtrl = TextEditingController();
  final fechaFabCtrl = TextEditingController();
  final fechaVenCtrl = TextEditingController();
  final cantidadInicialCtrl = TextEditingController();
  final cantidadDisponibleCtrl = TextEditingController();
  final codigoCtrl = TextEditingController();

  bool requiereRefrigeracion = false;
  bool activo = true;

  Widget campo(String texto, TextEditingController controlador) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controlador,
        decoration: InputDecoration(
          labelText: texto,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void limpiar() {
    nombreCtrl.clear();
    principioCtrl.clear();
    presentacionCtrl.clear();
    fabricanteCtrl.clear();
    stockMinimoCtrl.clear();
    loteCtrl.clear();
    fechaFabCtrl.clear();
    fechaVenCtrl.clear();
    cantidadInicialCtrl.clear();
    cantidadDisponibleCtrl.clear();
    codigoCtrl.clear();

    setState(() {
      requiereRefrigeracion = false;
      activo = true;
    });
  }

  void guardar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Datos guardados de prueba")));
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    principioCtrl.dispose();
    presentacionCtrl.dispose();
    fabricanteCtrl.dispose();
    stockMinimoCtrl.dispose();
    loteCtrl.dispose();
    fechaFabCtrl.dispose();
    fechaVenCtrl.dispose();
    cantidadInicialCtrl.dispose();
    cantidadDisponibleCtrl.dispose();
    codigoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicamentos")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Datos del medicamento",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            campo("Nombre", nombreCtrl),
            campo("Principio activo", principioCtrl),
            campo("Presentación", presentacionCtrl),
            campo("Fabricante", fabricanteCtrl),
            campo("Stock mínimo", stockMinimoCtrl),

            CheckboxListTile(
              title: const Text("¿Requiere refrigeración?"),
              value: requiereRefrigeracion,
              onChanged: (value) {
                setState(() {
                  requiereRefrigeracion = value ?? false;
                });
              },
            ),

            CheckboxListTile(
              title: const Text("Activo"),
              value: activo,
              onChanged: (value) {
                setState(() {
                  activo = value ?? true;
                });
              },
            ),

            const SizedBox(height: 20),
            const Text(
              "Datos del lote",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            campo("Número de lote", loteCtrl),
            campo("Fecha de fabricación", fechaFabCtrl),
            campo("Fecha de vencimiento", fechaVenCtrl),
            campo("Cantidad inicial", cantidadInicialCtrl),
            campo("Cantidad disponible", cantidadDisponibleCtrl),
            campo("Código de barras", codigoCtrl),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: guardar,
                    child: const Text("Guardar"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: limpiar,
                    child: const Text("Limpiar"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
